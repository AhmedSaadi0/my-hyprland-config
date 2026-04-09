// services/SystemService.qml

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io

import "root:/config"
import "root:/services"

Singleton {
    id: root

    // =========================================================
    // Boot Analysis
    // =========================================================

    property string bootAnalysisStatus: "IDLE"
    property string bootStatusTitle: "System Check"
    property string bootStatusIcon: ""
    property string bootStatusColor: "green"
    property string aiBootSummary: "Waiting for analysis..."
    property string bootTimeText: "--"
    property var bootLogsModel: []

    function refreshBootDetails() {
        if (bootAnalysisStatus === "LOADING")
            return;

        console.info("[SystemService] Starting Boot Analysis...");
        bootAnalysisStatus = "LOADING";

        const baseCommand = App.scripts.python.callBootAnalysisAi;
        const extraArgs = ["--message", "Analyze Boot Logs"];

        AiService.sendRequest(baseCommand, extraArgs, function (data) {
            if (data && data.title) {
                console.info("[SystemService] AI Analysis Received: " + data.title);

                root.bootStatusTitle = data.title;
                root.bootStatusIcon = data.icon;
                root.bootStatusColor = data.status_color;
                root.aiBootSummary = data.summary;
                root.bootTimeText = data.boot_duration;
                root.bootLogsModel = data.logs;
                root.bootAnalysisStatus = "SUCCESS";
            } else {
                console.error("[SystemService] Data received but structure is unexpected");
                root.bootAnalysisStatus = "ERROR";
            }
        }, function (errorMessage) {
            console.error("[SystemService] AI Process Error: " + errorMessage);
            root.bootAnalysisStatus = "ERROR";
        });
    }

    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: root.refreshBootDetails()
    }

    // =========================================================
    // Hardware State
    // =========================================================

    // --- Audio ---
    readonly property real volume: Audio.volume
    readonly property bool isMuted: Audio.muted
    readonly property string volumeIcon: {
        if (isMuted)
            return "";
        if (volume <= 0.0)
            return "";
        if (volume < 0.5)
            return "";
        return "";
    }

    // --- Brightness ---
    readonly property real brightness: Brightness.brightness
    readonly property string brightnessIcon: {
        if (brightness < 0.3)
            return "󰃞";
        if (brightness < 0.7)
            return "󰃟";
        return "󰃠";
    }

    // --- Battery ---
    readonly property var _bat: UPower.displayDevice ?? (UPower.devices.values.length > 0 ? UPower.devices.values[0] : null)
    readonly property bool hasBattery: UPower.devices.values.some(device => device.type === UPowerDeviceType.Battery)
    readonly property real batteryPercent: _bat ? _bat.percentage : 0
    readonly property int batteryState: _bat ? _bat.state : 0
    readonly property bool isCharging: batteryState === 1 || batteryState === 4
    readonly property string batteryIcon: {
        const dischargeIcons = ['󰁺', '󰁻', '󰁼', '󰁽', '󰁾', '󰁿', '󰂀', '󰂁', '󰂂', '󰁹'];
        const chargeIcons = ['󰢜', '󰂆', '󰂇', '󰂈', '󰢝', '󰂉', '󰢞', '󰂊', '󰂋', '󰂅'];
        let index = Math.min(9, Math.floor(batteryPercent * 10));
        if (batteryPercent > 0 && index < 0)
            index = 0;
        if (index < 0 || index > 9)
            return "󰂃";
        return isCharging ? chargeIcons[index] : dischargeIcons[index];
    }

    // --- CPU & RAM ---
    property real cpuUsage: 0.0
    property real ramUsage: 0.0
    readonly property bool isCpuHigh: cpuUsage >= (App.cpuHighLoadThreshold / 100)
    readonly property bool isRamHigh: ramUsage >= (App.ramHighLoadThreshold / 100)
    property real _lastCpuUsage: -1
    property real _lastRamUsage: -1
    property var _cpuAlertState: ({
            active: false,
            lastAlertAt: 0,
            breachedAt: 0,
            lastAlertProcessKey: "",
            episodeProcessKey: "",
            hasSentCurrentEpisode: false,
            requestPending: false
        })
    property var _ramAlertState: ({
            active: false,
            lastAlertAt: 0,
            breachedAt: 0,
            lastAlertProcessKey: "",
            episodeProcessKey: "",
            hasSentCurrentEpisode: false,
            requestPending: false
        })
    property var _resourceDiagnosticCallbacks: ({
            cpu: [],
            ram: []
        })
    property var _resourceDiagnosticQueue: []
    property string _activeResourceDiagnosticAction: ""
    property string _resourceDiagnosticStdoutText: ""
    property string _resourceDiagnosticStderrText: ""
    property int _resourceDiagnosticExitCode: 0
    property int _resourceDiagnosticExitStatus: 0

    // --- Temperature ---
    property real cpuMaxTemp: 0.0
    property real gpuMaxTemp: 0.0
    property real storageMaxTemp: 0.0
    property real _lastMaxTemp: -1

    // --- Keyboard Layout ---
    property string currentLayout: "EN"

    signal cpuSampled(real previousValue, real currentValue)
    signal ramSampled(real previousValue, real currentValue)
    signal temperatureSampled(real previousMax, real currentMax)
    signal cpuAlert(real value, bool isReminder, int activeForMs)
    signal ramAlert(real value, bool isReminder, int activeForMs)
    signal cpuNormal
    signal ramNormal

    function _formatLayout(rawName) {
        const lower = rawName.toLowerCase();
        if (lower.includes("arabic"))
            return "AR";
        if (lower.includes("english"))
            return "EN";
        return rawName.substring(0, 2).toUpperCase();
    }

    function _getTopProcessKey(kind, topList) {
        if (!topList || !topList.length)
            return "";

        const top = topList[0];
        if (top.pid !== undefined && top.pid !== null)
            return `${top.pid}:${top.name || ""}`;
        return top.name || "";
    }

    function _defaultResourceDiagnosticResult() {
        return [];
    }

    function _readResourceDiagnosticOutput(rawText) {
        const text = (rawText || "").toString().trim();
        if (!text)
            return _defaultResourceDiagnosticResult();

        try {
            const parsed = JSON.parse(text);
            if (parsed && !parsed.error && Array.isArray(parsed))
                return parsed;
            return _defaultResourceDiagnosticResult();
        } catch (e) {
            console.error(`[SystemService] Failed to parse resource diagnostics output: ${e}`);
            return _defaultResourceDiagnosticResult();
        }
    }

    function _flushResourceCallbacks(callbacks, data) {
        const pending = callbacks.slice();
        callbacks.length = 0;

        for (let i = 0; i < pending.length; i++)
            pending[i](data);
    }

    function _finishResourceDiagnosticRequest(action, data) {
        if (!action)
            return;

        const callbacks = _resourceDiagnosticCallbacks[action] || [];
        _resourceDiagnosticCallbacks[action] = [];
        _flushResourceCallbacks(callbacks, data);
        _activeResourceDiagnosticAction = "";
        _pumpResourceDiagnosticsQueue();
    }

    function _enqueueResourceDiagnosticRequest(action, callback) {
        if (!_resourceDiagnosticCallbacks[action])
            _resourceDiagnosticCallbacks[action] = [];

        _resourceDiagnosticCallbacks[action].push(callback);

        if (_activeResourceDiagnosticAction === action || _resourceDiagnosticQueue.indexOf(action) !== -1)
            return;

        _resourceDiagnosticQueue.push(action);
        _pumpResourceDiagnosticsQueue();
    }

    function _pumpResourceDiagnosticsQueue() {
        if (_activeResourceDiagnosticAction || !_resourceDiagnosticQueue.length)
            return;

        _activeResourceDiagnosticAction = _resourceDiagnosticQueue.shift();
        _resourceDiagnosticStdoutText = "";
        _resourceDiagnosticStderrText = "";
        _resourceDiagnosticExitCode = 0;
        _resourceDiagnosticExitStatus = 0;
        resourceDiagnosticsProc.command = [...App.scripts.python.systemDiagnosticsCommand, "--action", _activeResourceDiagnosticAction];
        resourceDiagnosticsProc.running = true;
    }

    function _resetResourceAlertState(kind, notifyNormal) {
        const state = kind === "cpu" ? root._cpuAlertState : root._ramAlertState;

        state.active = false;
        state.breachedAt = 0;
        state.episodeProcessKey = "";
        state.hasSentCurrentEpisode = false;
        state.requestPending = false;

        if (notifyNormal) {
            if (kind === "cpu")
                root.cpuNormal();
            else
                root.ramNormal();
        }
    }

    function _emitResourceAlert(kind, currentValue, isReminder, activeForMs) {
        if (kind === "cpu")
            root.cpuAlert(currentValue, isReminder, activeForMs);
        else
            root.ramAlert(currentValue, isReminder, activeForMs);
    }

    function _evaluateResourceEpisode(kind, currentValue, procKey) {
        const state = kind === "cpu" ? root._cpuAlertState : root._ramAlertState;
        const now = Date.now();
        const cooldownExpired = state.lastAlertAt === 0 || (now - state.lastAlertAt >= App.resourceAlertCooldownMs);
        const processChanged = procKey && state.lastAlertProcessKey && procKey !== state.lastAlertProcessKey;

        state.episodeProcessKey = procKey || state.episodeProcessKey;

        if (!state.hasSentCurrentEpisode) {
            if (!state.lastAlertProcessKey || !procKey || processChanged || cooldownExpired) {
                state.hasSentCurrentEpisode = true;
                state.lastAlertAt = now;
                state.lastAlertProcessKey = procKey || state.lastAlertProcessKey;
                _emitResourceAlert(kind, currentValue, false, 0);
            }
            return;
        }

        if (!cooldownExpired)
            return;

        state.lastAlertAt = now;
        state.lastAlertProcessKey = procKey || state.episodeProcessKey || state.lastAlertProcessKey;
        _emitResourceAlert(kind, currentValue, true, Math.max(0, now - state.breachedAt));
    }

    function _resolveResourceEpisode(kind, currentValue) {
        const state = kind === "cpu" ? root._cpuAlertState : root._ramAlertState;

        if (state.requestPending)
            return;

        state.requestPending = true;
        _enqueueResourceDiagnosticRequest(kind, function (topList) {
            state.requestPending = false;

            const latestValue = kind === "cpu" ? root.cpuUsage : root.ramUsage;
            const threshold = kind === "cpu" ? (App.cpuHighLoadThreshold / 100.0) : (App.ramHighLoadThreshold / 100.0);
            if (!state.active || latestValue < threshold)
                return;

            const procKey = root._getTopProcessKey(kind, topList);
            root._evaluateResourceEpisode(kind, latestValue, procKey);
        });
    }

    function _handleResourceAlert(kind, currentValue) {
        const threshold = kind === "cpu" ? (App.cpuHighLoadThreshold / 100.0) : (App.ramHighLoadThreshold / 100.0);
        const alertsEnabled = kind === "cpu" ? App.enableHighCpuAlert : App.enableHighRamAlert;
        const state = kind === "cpu" ? root._cpuAlertState : root._ramAlertState;

        if (!alertsEnabled) {
            if (state.active)
                _resetResourceAlertState(kind, true);
            return;
        }

        if (currentValue < threshold) {
            if (state.active)
                _resetResourceAlertState(kind, true);
            return;
        }

        if (!state.active) {
            state.active = true;
            state.breachedAt = Date.now();
            state.episodeProcessKey = "";
            state.hasSentCurrentEpisode = false;
            _resolveResourceEpisode(kind, currentValue);
            return;
        }

        if (!state.hasSentCurrentEpisode) {
            if (state.episodeProcessKey)
                _evaluateResourceEpisode(kind, currentValue, state.episodeProcessKey);
            return;
        }

        if (Date.now() - state.lastAlertAt < App.resourceAlertCooldownMs)
            return;

        _evaluateResourceEpisode(kind, currentValue, state.episodeProcessKey || state.lastAlertProcessKey);
    }

    onIsCpuHighChanged: {
        if (!isCpuHigh)
            _handleResourceAlert("cpu", cpuUsage);
    }

    onIsRamHighChanged: {
        if (!isRamHigh)
            _handleResourceAlert("ram", ramUsage);
    }

    Process {
        id: hardwareMonitorProc
        command: App.scripts.python.systemMonitorCommand // مسار سكربت البايثون الموحد
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    var metrics = JSON.parse(data.trim());

                    if (metrics.error) {
                        console.warn("[SystemService] Monitor script error:", metrics.error);
                        return;
                    }

                    // --- 1. تحديث المعالج وإرسال الإشارة ---
                    var prevCpu = root.cpuUsage;
                    root.cpuUsage = metrics.cpu / 100.0;
                    root.cpuSampled(prevCpu, root.cpuUsage);
                    root._handleResourceAlert("cpu", root.cpuUsage);

                    // --- 2. تحديث الرام وإرسال الإشارة ---
                    var prevRam = root.ramUsage;
                    root.ramUsage = metrics.ram / 100.0;
                    root.ramSampled(prevRam, root.ramUsage);
                    root._handleResourceAlert("ram", root.ramUsage);

                    // --- 3. تحديث الحرارة وإرسال الإشارة ---
                    var prevTemp = root.cpuMaxTemp;
                    root.cpuMaxTemp = metrics.temp;
                    root.temperatureSampled(prevTemp, root.cpuMaxTemp);

                } catch (e) {
                    console.error("[SystemService] Error parsing JSON:", e, "Data:", data);
                }
            }
        }
    }

    Process {
        id: resourceDiagnosticsProc

        stdout: StdioCollector {
            onStreamFinished: {
                root._resourceDiagnosticStdoutText = this.text.toString();
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                root._resourceDiagnosticStderrText = this.text.toString();
            }
        }

        onExited: (exitCode, exitStatus) => {
            root._resourceDiagnosticExitCode = exitCode;
            root._resourceDiagnosticExitStatus = exitStatus;
        }

        onRunningChanged: {
            if (running)
                return;

            const action = root._activeResourceDiagnosticAction;

            if (root._resourceDiagnosticStderrText.trim().length)
                console.error(`[SystemService] Resource diagnostics stderr for ${action}: ${root._resourceDiagnosticStderrText.trim()}`);

            if (root._resourceDiagnosticExitCode !== 0) {
                console.error(`[SystemService] Resource diagnostics failed for ${action} with exit code ${root._resourceDiagnosticExitCode} (${root._resourceDiagnosticExitStatus})`);
                root._finishResourceDiagnosticRequest(action, root._defaultResourceDiagnosticResult());
                return;
            }

            root._finishResourceDiagnosticRequest(action, root._readResourceDiagnosticOutput(root._resourceDiagnosticStdoutText));
        }
    }

    // Process {
    //     id: cpuProc
    //     command: App.scripts.bash.cpuCommand
    //     running: true
    //
    //     stdout: SplitParser {
    //         onRead: data => {
    //             console.info("CPU USAGE -> " + root.cpuUsage);
    //             const val = parseFloat(data.trim());
    //             if (isNaN(val))
    //                 return;
    //
    //             const prev = root._lastCpuUsage;
    //             root.cpuUsage = val / 100.0;
    //             root.cpuSampled(prev, root.cpuUsage);
    //             root._lastCpuUsage = root.cpuUsage;
    //             console.info("CPU USAGE -> " + root.cpuUsage);
    //         }
    //     }
    // }

    // Process {
    //     id: ramProc
    //     command: App.scripts.bash.ramCommand
    //     running: true
    //
    //     stdout: SplitParser {
    //         onRead: data => {
    //             const val = parseFloat(data.trim());
    //             if (isNaN(val))
    //                 return;
    //
    //             const prev = root._lastRamUsage;
    //             root.ramUsage = val / 100.0;
    //             root.ramSampled(prev, root.ramUsage);
    //             root._lastRamUsage = root.ramUsage;
    //         }
    //     }
    // }

    Process {
        id: tempProc
        command: [...App.scripts.python.systemDiagnosticsCommand, "--action", "temps"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim());
                    const prevMax = root._lastMaxTemp;

                    root.cpuMaxTemp = parsed.cpu_max_temp || 0;
                    root.gpuMaxTemp = parsed.gpu_max_temp || 0;
                    root.storageMaxTemp = parsed.storage_max_temp || 0;

                    const currentMax = Math.max(root.cpuMaxTemp, root.gpuMaxTemp, root.storageMaxTemp);
                    root.temperatureSampled(prevMax, currentMax);
                    root._lastMaxTemp = currentMax;
                } catch (e) {
                    console.error("[SystemService] Temp JSON parse error:", e);
                }
            }
        }
    }

    Process {
        id: layoutListener
        command: ["sh", "-c", "nc -U $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | grep --line-buffered 'activelayout>>'"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(">>");
                if (parts.length > 1) {
                    const info = parts[1].split(",");
                    if (info.length > 1) {
                        const newLayout = info[1];
                        const formatted = root._formatLayout(newLayout);
                        if (root.currentLayout !== formatted)
                            root.currentLayout = formatted;
                    }
                }
            }
        }
    }
}

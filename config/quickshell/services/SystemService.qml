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
    // [جديد] خصائص تحليل الإقلاع (Boot Analysis)
    // =========================================================

    // الحالة: "IDLE", "LOADING", "SUCCESS", "ERROR"
    property string bootAnalysisStatus: "IDLE"
    property string bootStatusTitle: "System Check"
    property string bootStatusIcon: ""
    property string bootStatusColor: "green"
    property string aiBootSummary: "Waiting for analysis..."
    property string bootTimeText: "--"
    property var bootLogsModel: []

    // دالة التحديث
    function refreshBootDetails() {
        if (bootAnalysisStatus === "LOADING")
            return;

        console.info("[SystemService] Starting Boot Analysis...");
        bootAnalysisStatus = "LOADING";

        var baseCommand = App.scripts.python.callBootAnalysisAi;
        var extraArgs = ["--message", "Analyze Boot Logs"];

        // 3. الإرسال عبر خدمة الذكاء الاصطناعي
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
        interval: 3000 // 3 ثواني بعد الإقلاع
        running: true
        repeat: false
        onTriggered: root.refreshBootDetails()
    }

    // =========================================================
    // خصائص العتاد السابقة (كما هي بدون تغيير)
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
    property string currentLayout: "EN"
    property real _lastCpuPrev: -1
    property real _lastCpuCurr: -1
    property real _lastRamPrev: -1
    property real _lastRamCurr: -1

    // --- Temp ---
    property real cpuMaxTemp: 0.0
    property real gpuMaxTemp: 0.0
    property real storageMaxTemp: 0.0

    // --- Spike Analysis Events ---
    property ListModel eventsModel: ListModel {}
    property int _eventCounter: 0
    property real _prevMaxTemp: -1
    property var _lastSpikeAt: ({
            cpu: 0,
            ram: 0,
            temp: 0
        })
    property int _spikeCooldownMs: 60000
    property int _tempSpikeCooldownMs: 300000
    property int _procSpikeCooldownMs: 300000
    property var _lastProcSpikeAt: ({
            cpu: ({}),
            ram: ({})
        })
    property int _procAlertCooldownMs: 300000
    property var _lastProcAlertAt: ({
            cpu: ({}),
            ram: ({})
        })
    property var _lastAlertAt: ({
            cpu: 0,
            ram: 0
        })
    property real _cpuSpikeDelta: 0.25
    property real _ramSpikeDelta: 0.25
    property real _tempSpikeDelta: 8
    property real _tempHighThreshold: 85

    signal cpuAlert(real value)
    signal ramAlert(real value)
    signal cpuNormal
    signal ramNormal

    function _formatLayout(rawName) {
        let lower = rawName.toLowerCase();
        if (lower.includes("arabic"))
            return "AR";
        if (lower.includes("english"))
            return "EN";
        return rawName.substring(0, 2).toUpperCase();
    }

    onIsCpuHighChanged: {
        isCpuHigh ? _emitCpuAlert(cpuUsage) : cpuNormal();
    }
    onIsRamHighChanged: {
        isRamHigh ? _emitRamAlert(ramUsage) : ramNormal();
    }

    Process {
        id: cpuProc
        command: App.scripts.bash.cpuCommand
        stdout: SplitParser {
            onRead: data => {
                var val = parseFloat(data.trim());
                if (!isNaN(val)) {
                    var prev = root.cpuUsage;
                    root.cpuUsage = val / 100.0;
                    root._lastCpuPrev = prev;
                    root._lastCpuCurr = root.cpuUsage;
                }
            }
        }
    }

    Process {
        id: ramProc
        command: App.scripts.bash.ramCommand
        stdout: SplitParser {
            onRead: data => {
                var val = parseFloat(data.trim());
                if (!isNaN(val)) {
                    var prev = root.ramUsage;
                    root.ramUsage = val / 100.0;
                    root._lastRamPrev = prev;
                    root._lastRamCurr = root.ramUsage;
                }
            }
        }
    }

    Process {
        id: tempProc
        command: App.scripts.python.devicesTempCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.toString());
                    var prevMax = root._prevMaxTemp;

                    root.cpuMaxTemp = data.cpu_max_temp || 0;
                    root.gpuMaxTemp = data.gpu_max_temp || 0;
                    root.storageMaxTemp = data.storage_max_temp || 0;

                    var maxTemp = Math.max(root.cpuMaxTemp, root.gpuMaxTemp, root.storageMaxTemp);
                    root._checkTempSpike(prevMax, maxTemp);
                    root._prevMaxTemp = maxTemp;
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
                let parts = data.trim().split(">>");
                if (parts.length > 1) {
                    let info = parts[1].split(",");
                    if (info.length > 1) {
                        let newLayout = info[1];
                        let formatted = root._formatLayout(newLayout);
                        if (root.currentLayout !== formatted) {
                            root.currentLayout = formatted;
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: _updateTimer
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (cpuProc) {
                cpuProc.running = false;
                cpuProc.running = true;
            }
            if (ramProc) {
                ramProc.running = false;
                ramProc.running = true;
            }
        }
    }

    Timer {
        id: _tempTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (tempProc) {
                tempProc.running = false;
                tempProc.running = true;
            }
        }
    }

    function _checkCpuSpike(prev, curr) {
        if (prev < 0)
            return;
        const threshold = App.cpuHighLoadThreshold / 100;
        if (!_canTriggerSpike("cpu"))
            return;
        if (curr >= threshold) {
            const delta = curr - prev;
            _collectTopCpuProcesses(function (topList) {
                const procKey = _getTopProcessKey("cpu", topList);
                if (_isProcessOnCooldown("cpu", procKey))
                    return;
                _lastSpikeAt.cpu = Date.now();
                _markProcessSpike("cpu", procKey);
                _createSpikeEvent("CPU", Math.round(curr * 100), Math.round(prev * 100), Math.round(delta * 100), threshold * 100, topList, null);
            });
        }
    }

    function _checkRamSpike(prev, curr) {
        if (prev < 0)
            return;
        const threshold = App.ramHighLoadThreshold / 100;
        if (!_canTriggerSpike("ram"))
            return;
        if (curr >= threshold) {
            const delta = curr - prev;
            _collectTopRamProcesses(function (topList) {
                const procKey = _getTopProcessKey("ram", topList);
                if (_isProcessOnCooldown("ram", procKey))
                    return;
                _lastSpikeAt.ram = Date.now();
                _markProcessSpike("ram", procKey);
                _createSpikeEvent("RAM", Math.round(curr * 100), Math.round(prev * 100), Math.round(delta * 100), threshold * 100, topList, null);
            });
        }
    }

    function _checkTempSpike(prevMax, currMax) {
        if (prevMax < 0)
            return;
        if (!_canTriggerSpike("temp"))
            return;
        if (currMax >= _tempHighThreshold) {
            const delta = currMax - prevMax;
            _lastSpikeAt.temp = Date.now();
            _createSpikeEvent("TEMP", Math.round(currMax), Math.round(prevMax), Math.round(delta), _tempHighThreshold, [], {
                cpu_max: root.cpuMaxTemp,
                gpu_max: root.gpuMaxTemp,
                storage_max: root.storageMaxTemp
            });
        }
    }

    function _canTriggerSpike(kind) {
        const now = Date.now();
        return now - _lastSpikeAt[kind] >= _getSpikeCooldownMs(kind);
    }

    function _getSpikeCooldownMs(kind) {
        if (kind === "temp")
            return _tempSpikeCooldownMs;
        return _spikeCooldownMs;
    }

    function _getTopProcessKey(kind, topList) {
        if (!topList || !topList.length)
            return "";
        const top = topList[0];
        if (kind === "ram") {
            if (top.pid !== undefined && top.pid !== null)
                return `${top.pid}:${top.name || ""}`;
        }
        return top.name || "";
    }

    function _isProcessOnCooldown(kind, procKey) {
        if (!procKey)
            return false;
        const last = _lastProcSpikeAt[kind][procKey] || 0;
        return Date.now() - last < _procSpikeCooldownMs;
    }

    function _markProcessSpike(kind, procKey) {
        if (!procKey)
            return;
        _lastProcSpikeAt[kind][procKey] = Date.now();
    }

    function _isAlertOnCooldown(kind, procKey) {
        const now = Date.now();
        if (procKey) {
            const last = _lastProcAlertAt[kind][procKey] || 0;
            return now - last < _procAlertCooldownMs;
        }
        return now - _lastAlertAt[kind] < _procAlertCooldownMs;
    }

    function _markAlert(kind, procKey) {
        const now = Date.now();
        if (procKey)
            _lastProcAlertAt[kind][procKey] = now;
        _lastAlertAt[kind] = now;
    }

    function _emitCpuAlert(value) {
        _collectTopCpuProcesses(function (topList) {
            const procKey = _getTopProcessKey("cpu", topList);
            if (_isAlertOnCooldown("cpu", procKey))
                return;
            _markAlert("cpu", procKey);
            cpuAlert(value);
            const curr = _lastCpuCurr >= 0 ? _lastCpuCurr : value;
            const prev = _lastCpuPrev >= 0 ? _lastCpuPrev : curr;
            const threshold = App.cpuHighLoadThreshold;
            const delta = curr - prev;
            _createSpikeEvent("CPU", Math.round(curr * 100), Math.round(prev * 100), Math.round(delta * 100), threshold, topList, null);
        });
    }

    function _emitRamAlert(value) {
        _collectTopRamProcesses(function (topList) {
            const procKey = _getTopProcessKey("ram", topList);
            if (_isAlertOnCooldown("ram", procKey))
                return;
            _markAlert("ram", procKey);
            ramAlert(value);
            const curr = _lastRamCurr >= 0 ? _lastRamCurr : value;
            const prev = _lastRamPrev >= 0 ? _lastRamPrev : curr;
            const threshold = App.ramHighLoadThreshold;
            const delta = curr - prev;
            _createSpikeEvent("RAM", Math.round(curr * 100), Math.round(prev * 100), Math.round(delta * 100), threshold, topList, null);
        });
    }

    function _createSpikeEvent(type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride) {
        const eventId = `evt_${Date.now()}_${_eventCounter++}`;
        const severity = (type === "TEMP" ? (currentValue >= _tempHighThreshold + 10 ? "CRITICAL" : "WARNING") : (currentValue >= thresholdValue ? "WARNING" : "NORMAL"));

        eventsModel.insert(0, {
            eventId: eventId,
            type: type,
            value: type === "TEMP" ? `${currentValue}°C` : `${currentValue}%`,
            severity: severity,
            timestamp: _formatTime(new Date()),
            aiAnalysis: "Analyzing... Please wait.",
            isLoading: true,
            aiModel: App.systemAiModel || "System AI"
        });

        _requestSpikeAnalysis(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride);
    }

    function _requestSpikeAnalysis(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride) {
        if (type === "CPU") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, null);
                return;
            }
            _collectTopCpuProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, null);
            });
            return;
        }
        if (type === "RAM") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, null);
                return;
            }
            _collectTopRamProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, null);
            });
            return;
        }
        if (type === "TEMP") {
            _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, [], tempsOverride || {
                cpu_max: root.cpuMaxTemp,
                gpu_max: root.gpuMaxTemp,
                storage_max: root.storageMaxTemp
            });
        }
    }

    function _collectTopCpuProcesses(callback) {
        topCpuProc.onDone = callback;
        topCpuProc.running = false;
        topCpuProc.running = true;
    }

    function _collectTopRamProcesses(callback) {
        topRamProc.onDone = callback;
        topRamProc.running = false;
        topRamProc.running = true;
    }

    function _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, temps) {
        const payload = {
            event_type: type,
            current_value: currentValue,
            previous_value: prevValue,
            delta: deltaValue,
            threshold: thresholdValue,
            timestamp: new Date().toISOString(),
            top_processes: topList || [],
            temps: temps || {
                cpu_max: root.cpuMaxTemp,
                gpu_max: root.gpuMaxTemp,
                storage_max: root.storageMaxTemp
            }
        };

        AiService.sendRequest(App.scripts.python.callSpikeAnalysisAi, ["--message", JSON.stringify(payload)], function (data) {
            root._applySpikeAnalysis(eventId, data);
        }, function (errorMessage) {
            root._applySpikeAnalysis(eventId, {
                title: "Analysis Failed",
                severity: "warning",
                analysis: errorMessage || "Failed to analyze spike.",
                causes: [],
                actions: []
            });
        });
    }

    function _applySpikeAnalysis(eventId, data) {
        const idx = _findEventIndex(eventId);
        if (idx === -1)
            return;

        const lines = [];
        if (data.title)
            lines.push(data.title);
        if (data.analysis)
            lines.push(data.analysis);
        if (data.causes && data.causes.length)
            lines.push("Causes: " + data.causes.join(", "));
        if (data.actions && data.actions.length)
            lines.push("Actions: " + data.actions.join(", "));

        eventsModel.setProperty(idx, "aiAnalysis", lines.join("\n"));
        eventsModel.setProperty(idx, "isLoading", false);

        if (data.severity) {
            const sev = data.severity.toUpperCase();
            eventsModel.setProperty(idx, "severity", sev === "INFO" ? "NORMAL" : sev);
        }
    }

    function _findEventIndex(eventId) {
        for (var i = 0; i < eventsModel.count; i++) {
            if (eventsModel.get(i).eventId === eventId)
                return i;
        }
        return -1;
    }

    function _formatTime(dt) {
        const hh = dt.getHours().toString().padStart(2, "0");
        const mm = dt.getMinutes().toString().padStart(2, "0");
        const ss = dt.getSeconds().toString().padStart(2, "0");
        return `${hh}:${mm}:${ss}`;
    }

    Process {
        id: topCpuProc
        property var onDone: null
        command: App.scripts.python.topCpuUsageCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var list = JSON.parse(this.text.toString());
                    if (topCpuProc.onDone)
                        topCpuProc.onDone(list);
                } catch (e) {
                    if (topCpuProc.onDone)
                        topCpuProc.onDone([]);
                } finally {
                    topCpuProc.onDone = null;
                }
            }
        }
    }

    Process {
        id: topRamProc
        property var onDone: null
        command: App.scripts.python.topRamUsageCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var list = JSON.parse(this.text.toString());
                    if (topRamProc.onDone)
                        topRamProc.onDone(list);
                } catch (e) {
                    if (topRamProc.onDone)
                        topRamProc.onDone([]);
                } finally {
                    topRamProc.onDone = null;
                }
            }
        }
    }

    NibrasShellShortcut {
        name: "testHighCpu"
        onPressed: {
            cpuAlert(0.5);
        }
    }

    NibrasShellShortcut {
        name: "testHighRam"
        onPressed: {
            ramAlert(0.50);
        }
    }
}

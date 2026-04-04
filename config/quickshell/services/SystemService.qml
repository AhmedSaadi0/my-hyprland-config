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
    signal cpuAlert(real value)
    signal ramAlert(real value)
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

    onIsCpuHighChanged: {
        if (isCpuHigh)
            cpuAlert(cpuUsage);
        else
            cpuNormal();
    }

    onIsRamHighChanged: {
        if (isRamHigh)
            ramAlert(ramUsage);
        else
            ramNormal();
    }

    Process {
        id: cpuProc
        command: App.scripts.bash.cpuCommand
        running: true

        stdout: SplitParser {
            onRead: data => {
                const val = parseFloat(data.trim());
                if (isNaN(val))
                    return;

                const prev = root._lastCpuUsage;
                root.cpuUsage = val / 100.0;
                root.cpuSampled(prev, root.cpuUsage);
                root._lastCpuUsage = root.cpuUsage;
            }
        }
    }

    Process {
        id: ramProc
        command: App.scripts.bash.ramCommand
        running: true

        stdout: SplitParser {
            onRead: data => {
                const val = parseFloat(data.trim());
                if (isNaN(val))
                    return;

                const prev = root._lastRamUsage;
                root.ramUsage = val / 100.0;
                root.ramSampled(prev, root.ramUsage);
                root._lastRamUsage = root.ramUsage;
            }
        }
    }

    Process {
        id: tempProc
        command: App.scripts.python.devicesTempCommand
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

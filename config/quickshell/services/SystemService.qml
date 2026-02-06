// services/SystemService.qml

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io

import "root:/config"

Singleton {
    id: root

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

    // --- Battery (Logic Moved Here) ---
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

        if (isCharging) {
            return chargeIcons[index];
        } else {
            return dischargeIcons[index];
        }
    }

    property real cpuUsage: 0.0
    property real ramUsage: 0.0
    readonly property bool isCpuHigh: cpuUsage >= (App.cpuHighLoadThreshold / 100)
    readonly property bool isRamHigh: ramUsage >= (App.ramHighLoadThreshold / 100)

    property string currentLayout: "EN"

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
        if (isCpuHigh) {
            cpuAlert(cpuUsage);
        } else {
            cpuNormal();
        }
    }

    onIsRamHighChanged: {
        if (isRamHigh) {
            ramAlert(ramUsage);
        } else {
            ramNormal();
        }
    }

    Process {
        id: cpuProc
        command: App.scripts.bash.cpuCommand

        stdout: SplitParser {
            onRead: data => {
                var val = parseFloat(data.trim());
                if (!isNaN(val)) {
                    root.cpuUsage = val / 100.0;
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
                    root.ramUsage = val / 100.0;
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
                            console.info("Keyboard Layout Changed to: " + formatted);
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

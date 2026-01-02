// services/Brightness.qml

pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import Quickshell
import Quickshell.Io
import QtQuick

import "../config"

Singleton {
    id: root

    property var ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances

    // السطوع العام للمراقبة من الخارج
    property real brightness: 0

    function getMonitorForScreen(): var {
        return monitors.find(m => m.modelData.name === Hyprland.focusedMonitor.name);
    }

    function increaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.modelData.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.1);
    }

    function decreaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.modelData.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness - 0.1);
    }

    reloadableId: "brightness"

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Variants {
        id: variants
        model: Quickshell.screens
        Monitor {}
    }

    Process {
        id: ddcProc
        command: ["ddcutil", "detect", "--brief"]
        stdout: SplitParser {
            splitMarker: "\n\n"
            onRead: data => {
                if (data.startsWith("Display ")) {
                    const lines = data.split("\n").map(l => l.trim());
                    root.ddcMonitors.push({
                        model: lines.find(l => l.startsWith("Monitor:")).split(":")[2],
                        busNum: lines.find(l => l.startsWith("I2C bus:")).split("/dev/i2c-")[1]
                    });
                }
            }
        }
        onExited: root.ddcMonitorsChanged()
    }

    Process {
        id: setProc
    }

    NibrasShellShortcut {
        name: "brightnessUp"
        onPressed: root.increaseBrightness()
    }

    NibrasShellShortcut {
        name: "brightnessDown"
        onPressed: root.decreaseBrightness()
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: root.ddcMonitors.some(m => m.model === modelData.model)
        readonly property string busNum: root.ddcMonitors.find(m => m.model === modelData.model)?.busNum ?? ""
        property real brightness

        readonly property Process initProc: Process {
            stdout: SplitParser {
                onRead: data => {
                    const [, , , current, max] = data.split(" ");
                    monitor.brightness = parseInt(current) / parseInt(max);

                    // تحديث القيمة العامة إذا كان هو الشاشة المركزة
                    if (monitor.modelData.name === Hyprland.focusedMonitor.name) {
                        root.brightness = monitor.brightness;
                    }
                }
            }
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            const rounded = Math.round(value * 100);
            if (Math.round(brightness * 100) === rounded)
                return;
            brightness = value;

            // تحديث القيم العامة
            if (modelData.name === Hyprland.focusedMonitor.name) {
                root.brightness = value;
            }

            setProc.command = isDdc ? ["ddcutil", "-b", busNum, "setvcp", "10", rounded] : ["brightnessctl", "s", `${rounded}%`];
            setProc.startDetached();
        }

        onBusNumChanged: {
            initProc.command = isDdc ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"] : ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`];
            initProc.running = true;
        }

        Component.onCompleted: {
            initProc.command = isDdc ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"] : ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`];
            initProc.running = true;
        }
    }
}

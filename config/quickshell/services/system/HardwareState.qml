// services/system/HardwareState.qml

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io

import "root:/services"

QtObject {
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

    // --- Battery ---
    readonly property var _bat: UPower.displayDevice ?? (UPower.devices.values.length > 0 ? UPower.devices.values[0] : null)
    readonly property bool hasBattery: UPower.devices.values.some(device => device.type === UPowerDeviceType.Battery)
    readonly property real batteryPercent: _bat ? _bat.percentage : 0
    readonly property int batteryState: _bat ? _bat.state : 0
    readonly property bool isCharging: batteryState === 1 || batteryState === 4
    readonly property var _batteryDischargeIcons: ['󰁺', '󰁻', '󰁼', '󰁽', '󰁾', '󰁿', '󰂀', '󰂁', '󰂂', '󰁹']
    readonly property var _batteryChargeIcons: ['󰢜', '󰂆', '󰂇', '󰂈', '󰢝', '󰂉', '󰢞', '󰂊', '󰂋', '󰂅']
    readonly property string batteryIcon: {
        const index = Math.min(9, Math.floor(batteryPercent * 10));
        if (index < 0 || index > 9)
            return "󰂃";
        return isCharging ? _batteryChargeIcons[index] : _batteryDischargeIcons[index];
    }

    // --- Keyboard Layout ---
    property string currentLayout: "EN"

    function _formatLayout(rawName) {
        const lower = rawName.toLowerCase();
        if (lower.includes("arabic"))
            return "AR";
        if (lower.includes("english"))
            return "EN";
        return rawName.substring(0, 2).toUpperCase();
    }

    property Process _layoutListener: Process {
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

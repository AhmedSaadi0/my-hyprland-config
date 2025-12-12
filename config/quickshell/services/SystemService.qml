pragma Singleton
import QtQuick
import Quickshell.Services.UPower

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

    // --- Battery (Logic Moved Here) ---
    readonly property var _bat: UPower.displayDevice ?? (UPower.devices.values.length > 0 ? UPower.devices.values[0] : null)

    readonly property real batteryPercent: _bat ? _bat.percentage : 0
    // 1: Charging, 2: Discharging, 4: Full
    readonly property int batteryState: _bat ? _bat.state : 0
    readonly property bool isCharging: batteryState === 1 || batteryState === 4

    // منطق الأيقونات الخاص بك (تم نقله إلى هنا)
    readonly property string batteryIcon: {
        const dischargeIcons = ['󰁺', '󰁻', '󰁼', '󰁽', '󰁾', '󰁿', '󰂀', '󰂁', '󰂂', '󰁹'];
        const chargeIcons = ['󰢜', '󰂆', '󰂇', '󰂈', '󰢝', '󰂉', '󰢞', '󰂊', '󰂋', '󰂅'];

        // تحويل النسبة (0.0 - 1.0) إلى فهرس (0 - 9)
        let index = Math.min(9, Math.floor(batteryPercent * 10));

        // تصحيح القيم الصغيرة جداً
        if (batteryPercent > 0 && index < 0)
            index = 0;

        // حماية من الخطأ إذا كانت المصفوفة فارغة أو الفهرس غير صحيح
        if (index < 0 || index > 9)
            return "󰂃";

        if (isCharging) {
            return chargeIcons[index];
        } else {
            return dischargeIcons[index];
        }
    }
}

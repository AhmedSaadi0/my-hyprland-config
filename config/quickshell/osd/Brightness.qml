import QtQuick
import Quickshell.Hyprland
import "../themes"
import "../components"
import "../services"

OsdPanelWindow {
    id: root

    target: Brightness
    sliderValue: Brightness.brightness
    watchSignal: "brightnessChanged"
    valueTextIcon: {
        const val = Brightness.brightness;
        if (val < 0.30) {
            return "󰃞";
        } else if (val < 0.70) {
            return "󰃟";
        } else {
            return "󰃠";
        }
    }
    valueTextColor: ThemeManager.selectedTheme.colors.volOsdFgColor
    bgColor: ThemeManager.selectedTheme.colors.volOsdBgColor
    onValueChanged: v => {
        const mon = Brightness.getMonitorForScreen();
        if (mon)
            mon.setBrightness(v);
    }
}

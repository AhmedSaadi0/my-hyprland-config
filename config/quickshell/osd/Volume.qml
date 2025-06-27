import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../themes"
import "../components"
import "../services"

OsdPanelWindow {
    id: root

    target: Audio
    sliderValue: Audio.volume
    valueTextIcon: {
        const vol = Audio.volume;
        if (Audio.muted) {
            return "";
        } else if (vol < 0.30) {
            return "";
        } else if (vol < 0.70) {
            return "";
        } else {
            return "";
        }
    }
    valueTextColor: ThemeManager.selectedTheme.colors.volOsdFgColor
    bgColor: ThemeManager.selectedTheme.colors.volOsdBgColor
    onValueChanged: v => Audio.setVolume(v)
}

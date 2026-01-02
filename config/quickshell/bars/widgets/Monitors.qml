import QtQuick.Layouts
import QtQuick

import "root:/components/monitors"
import "root:/themes"
import "root:/services"
import "root:/components"

RowLayout {
    // anchors.fill: parent
    // width: 120
    spacing: 6

    TopbarCircularProgress {
        id: brightnessUsage
        icon: "󰃠"
        value: Brightness.brightness
        iconFontSize: 10
        activeProcess: false
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont

        backgroundColor: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
        foregroundColor: ThemeManager.selectedTheme.colors.primary
        iconColor: ThemeManager.selectedTheme.colors.primary

        onValueChanged: function () {
            const percentage = value * 100;
            if (percentage >= 90) {
                brightnessUsage.icon = "󰃠"; // nf-mdi-brightness_7
            } else if (percentage >= 70) {
                brightnessUsage.icon = "󰃟"; // nf-mdi-brightness_6
            } else if (percentage >= 50) {
                brightnessUsage.icon = "󰃞"; // nf-mdi-brightness_5
            } else if (percentage >= 30) {
                brightnessUsage.icon = "󰃝"; // nf-mdi-brightness_4
            } else if (percentage > 10) {
                brightnessUsage.icon = "󰃛"; // nf-mdi-brightness_2
            } else {
                brightnessUsage.icon = "󰃚"; // nf-mdi-brightness_1
            }
        }
    }

    TopbarCircularProgress {
        id: audioUsage
        icon: ""
        value: Audio.volume
        iconFontSize: 10
        activeProcess: false

        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        backgroundColor: ThemeManager.selectedTheme.colors.secondary.alpha(0.2)
        foregroundColor: ThemeManager.selectedTheme.colors.secondary
        iconColor: ThemeManager.selectedTheme.colors.secondary

        readonly property bool muted: Audio.muted

        onMutedChanged: function () {
            const percentage = value * 100;
            if (Audio.muted) {
                audioUsage.icon = "󰖁";
            } else if (percentage >= 75) {
                audioUsage.icon = "";
            } else if (percentage >= 50) {
                audioUsage.icon = "󰕾";
            } else if (percentage > 0) {
                audioUsage.icon = "󰖀";
            } else {
                audioUsage.icon = "󰖁";
            }
        }

        onValueChanged: function () {
            const percentage = value * 100;
            if (Audio.muted) {
                audioUsage.icon = "󰖁";
            } else if (percentage >= 75) {
                audioUsage.icon = "";
            } else if (percentage >= 50) {
                audioUsage.icon = "󰕾";
            } else if (percentage > 0) {
                audioUsage.icon = "󰖀";
            } else {
                audioUsage.icon = "󰖁";
            }
        }
    }

    // Separator
    Rectangle {
        width: 1
        height: 16
        color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
        Layout.alignment: Qt.AlignVCenter
    }

    Tempreture {
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    }
    Battery {
        glowIcon: false
        iconColor: ThemeManager.selectedTheme.colors.primary
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        backgroundColor: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
        foregroundColor: ThemeManager.selectedTheme.colors.primary
    }
    Ram {
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    }
    Cpu {
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    }
}

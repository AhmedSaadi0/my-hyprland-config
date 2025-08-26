// windows/leftwindow/dashboard/settings/ActionsAndResets.qml

import QtQuick
import QtQuick.Layouts

import "root:/components"
import "root:/themes"

M3GroupBox {
    id: root
    title: "Actions & Resets"

    property var workingTheme: ({})

    Layout.fillWidth: true

    GridLayout {
        columns: 2
        Layout.fillWidth: true
        MButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 30
            text: "Reset Colors"
            onClicked: ThemeManager.resetColorSettings()
        }
        MButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 30
            text: "Reset Wallpapers"
            onClicked: ThemeManager.resetWallpaperSystemSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset Hyprland"
            onClicked: ThemeManager.resetHyprlandSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset Plasma/QT"
            onClicked: ThemeManager.resetPlasmaSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset GTK"
            onClicked: ThemeManager.resetGtkSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Next Wallpaper"
            onClicked: ThemeManager.switchToNextWallpaper()
            iconText: ""
            textPreferredWidth: 7
            enabled: workingTheme._enableDynamicWallpapers
        }
    }
}

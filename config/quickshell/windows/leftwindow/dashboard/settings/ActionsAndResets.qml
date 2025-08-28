// windows/leftwindow/dashboard/settings/ActionsAndResets.qml

import QtQuick
import QtQuick.Layouts

import "root:/components"
import "root:/themes"

M3GroupBox {
    id: root
    title: "Actions & Resets"

    property var workingTheme

    Layout.fillWidth: true

    signal resetColorSettings
    signal resetWallpaperSettings
    signal resetHyprlandSettings
    signal resetPlasmaSettings
    signal resetGtkSettings
    signal nextWallpaper

    GridLayout {
        columns: 2
        Layout.fillWidth: true
        MButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 30
            text: "Reset Colors"
            onClicked: root.resetColorSettings()
        }
        MButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 30
            text: "Reset Wallpapers"
            onClicked: root.resetWallpaperSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset Hyprland"
            onClicked: root.resetHyprlandSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset Plasma/QT"
            onClicked: root.resetPlasmaSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset GTK"
            onClicked: root.resetGtkSettings()
        }
        MButton {
            Layout.fillWidth: true
            text: "Next Wallpaper"
            onClicked: root.nextWallpaper()
            iconText: ""
            textPreferredWidth: 7
            enabled: workingTheme._enableDynamicWallpapers
        }
    }
}

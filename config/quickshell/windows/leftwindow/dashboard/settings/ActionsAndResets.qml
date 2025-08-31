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
    signal cleardUnusedOverlayImages

    GridLayout {
        columnSpacing: 3
        columns: 2
        Layout.fillWidth: true
        MButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 30
            text: "Reset Colors"
            onClicked: root.resetColorSettings()

            topRightRadius: 0
            bottomRightRadius: 0
        }
        MButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 30
            text: "Reset Wallpapers"
            onClicked: root.resetWallpaperSettings()

            topLeftRadius: 0
            bottomLeftRadius: 0
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset Hyprland"
            onClicked: root.resetHyprlandSettings()
            topRightRadius: 0
            bottomRightRadius: 0
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset Plasma/QT"
            onClicked: root.resetPlasmaSettings()
            topLeftRadius: 0
            bottomLeftRadius: 0
        }
        MButton {
            Layout.fillWidth: true
            text: "Reset GTK"
            onClicked: root.resetGtkSettings()
            topRightRadius: 0
            bottomRightRadius: 0
        }
        MButton {
            Layout.fillWidth: true
            text: "Next Wallpaper"
            onClicked: root.nextWallpaper()
            iconText: ""
            textPreferredWidth: 7
            enabled: workingTheme._enableDynamicWallpapers
            topLeftRadius: 0
            bottomLeftRadius: 0
        }
        MButton {
            Layout.fillWidth: true
            text: "Remove Unused Cache"
            onClicked: root.cleardUnusedOverlayImages()

            topRightRadius: 0
            bottomRightRadius: 0
        }
    }
}

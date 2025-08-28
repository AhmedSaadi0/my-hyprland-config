// settings/WallpaperSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "root:/components"

M3GroupBox {
    id: root
    title: "Wallpaper Settings"
    Layout.fillWidth: true

    property var workingTheme
    property var selectedTheme

    signal openFolderDialog
    signal openFileDialog
    signal dynamicColoringChanged

    GridLayout {
        columns: 1
        Layout.fillWidth: true
        rowSpacing: 10

        SettingSwitch {
            id: _enableDynamicWallpapersSwitch
            label: "Enable dynamic wallpapers"
            isChecked: workingTheme._enableDynamicWallpapers
            onIsCheckedChanged: {
                workingTheme._enableDynamicWallpapers = isChecked;
            }
        }

        SettingSwitch {
            label: "Dynamic colors from wallpaper"
            isChecked: workingTheme._enableDynamicColoring
            onIsCheckedChanged: {
                workingTheme._enableDynamicWallpapers = isChecked;
                if (isChecked) {
                    root.dynamicColoringChanged();
                }
            }
        }

        SettingTextField {
            label: "Wallpapers interval (ms)"
            textValue: workingTheme._dynamicWallpapersInterval
            selectedTheme: root.selectedTheme
        }

        SettingTextField {
            label: "Selected Wallpaper (index)"
            textValue: workingTheme._selectedWallpaperIndex
            selectedTheme: root.selectedTheme
        }

        SettingButton {
            label: "Wallpapers folder"
            enabled: _enableDynamicWallpapersSwitch.isChecked
            buttonText: workingTheme._dynamicWallpapersPath
            buttonIcon: ""
            onClicked: root.openFolderDialog()
        }

        SettingButton {
            label: "Static Wallpaper"
            enabled: !_enableDynamicWallpapersSwitch.isChecked
            buttonText: workingTheme._wallpaper
            buttonIcon: ""
            onClicked: root.openFileDialog()
        }
    }
}

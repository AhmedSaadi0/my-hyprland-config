// components/wallpaper_selector/WallpaperHeader.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "root:/themes"

RowLayout {
    id: root

    property bool isLoading: false
    property int sourceMode: 0

    signal refreshClicked
    signal closeClicked

    spacing: 12

    Text {
        text: "󰸉"
        font.pixelSize: 24
        font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
        color: ThemeManager.selectedTheme?.colors?.primary || "#fff"

        renderType: Text.QtRendering
        font.hintingPreference: Font.PreferNoHinting
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Text {
            text: qsTr("Wallpaper Selector")
            font.pixelSize: 16
            font.bold: true
            color: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
        }

        Text {
            text: root.sourceMode === 2 ? qsTr("Browse wallpapers from Wallhaven.cc") : qsTr("Select a wallpaper to apply")
            font.pixelSize: 11
            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
        }
    }

    // Refresh button
    Rectangle {
        width: 28
        height: 28
        radius: 6
        color: refreshMouseArea.containsMouse ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333" : "transparent"

        Text {
            anchors.centerIn: parent
            text: root.isLoading ? "󰦖" : "󰑐"
            font.pixelSize: 16
            font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"

            renderType: Text.QtRendering
            font.hintingPreference: Font.PreferNoHinting

            RotationAnimation on rotation {
                running: root.isLoading
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }

        MouseArea {
            id: refreshMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.refreshClicked()
        }
    }

    // Close button
    Rectangle {
        width: 28
        height: 28
        radius: 6
        color: closeMouseArea.containsMouse ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333" : "transparent"

        Text {
            anchors.centerIn: parent
            text: "󰅖"
            font.pixelSize: 16
            font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"

            renderType: Text.QtRendering
            font.hintingPreference: Font.PreferNoHinting
        }

        MouseArea {
            id: closeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeClicked()
        }
    }
}

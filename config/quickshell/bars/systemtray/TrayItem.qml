// bars/systemtray/TrayItem.qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick.Effects

import "root:/themes"

MouseArea {
    id: root

    required property SystemTrayItem modelData

    implicitWidth: ThemeManager.selectedTheme.dimensions.barWidgetsHeight - 6
    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: ThemeManager.selectedTheme.colors.primary
        opacity: root.containsPress ? 0.3 : (root.containsMouse ? 0.15 : 0)

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (modelData.hasMenu) {
            menu.open();
        }
    }

    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.window: root.QsWindow.window
    }

    IconImage {
        id: trayIconSource
        width: parent.implicitHeight - 8
        height: parent.implicitHeight - 8
        source: root.modelData.icon
        anchors.centerIn: parent
        visible: false

        smooth: true
        mipmap: true
    }

    MultiEffect {
        id: coloredIcon
        anchors.fill: trayIconSource
        source: trayIconSource

        colorization: 1.0
        colorizationColor: ThemeManager.selectedTheme.colors.topbarFgColorV2

        autoPaddingEnabled: true
    }

    Rectangle {
        id: tooltip
        visible: root.containsMouse && (modelData.title !== "" || modelData.tooltip !== "")

        anchors.bottom: parent.top
        anchors.bottomMargin: ThemeManager.selectedTheme.dimensions.spacingMedium
        anchors.horizontalCenter: parent.horizontalCenter

        width: tooltipText.width + (ThemeManager.selectedTheme.dimensions.spacingMedium * 2)
        height: tooltipText.height + ThemeManager.selectedTheme.dimensions.spacingSmall
        z: 100

        color: ThemeManager.selectedTheme.colors.topbarColor
        border.color: ThemeManager.selectedTheme.colors.primary
        border.width: 1
        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 4

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: (modelData.tooltip || modelData.title || "")
            color: ThemeManager.selectedTheme.colors.topbarFgColor
            font.family: ThemeManager.selectedTheme.typography.bodyFont
            font.pixelSize: ThemeManager.selectedTheme.typography.small
        }

        opacity: visible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }
}

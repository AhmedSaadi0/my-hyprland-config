// bars/systemtray/TrayItem.qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "root:/themes"
import "root:/config"
import "root:/utils"

MouseArea {
    id: root

    required property SystemTrayItem modelData

    implicitWidth: ThemeManager.selectedTheme.dimensions.barWidgetsHeight - 6
    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    readonly property bool needsAttention: modelData.status === Status.NeedsAttention
    readonly property string resolvedIconSource: {
        const icon = String(modelData.icon || "");
        if (icon === "") return "";
        if (Helper.isDirectImageSource(icon))
            return Helper.toImageSource(icon);
        return Quickshell.iconPath(icon, "application-x-executable");
    }

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: needsAttention ? ThemeManager.selectedTheme.colors.secondary : ThemeManager.selectedTheme.colors.primary
        opacity: root.containsPress ? 0.30 : (root.containsMouse ? 0.14 : (needsAttention ? 0.12 : 0))
        border.width: needsAttention ? 1 : 0
        border.color: needsAttention ? ThemeManager.selectedTheme.colors.secondary : "transparent"

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

    Rectangle {
        id: iconPlate
        anchors.centerIn: parent
        width: parent.implicitHeight - 2
        height: parent.implicitHeight - 2
        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 1.6
        color: root.containsPress ? ThemeManager.selectedTheme.colors.surfaceContainerHigh : "transparent"
        border.width: root.containsMouse ? 1 : 0
        border.color: ThemeManager.selectedTheme.colors.onSurfaceVariant.alpha(0.22)

        IconImage {
            id: trayIcon
            anchors.centerIn: parent
            width: parent.width - 7
            height: parent.height - 7
            source: root.resolvedIconSource
            asynchronous: true
            mipmap: true
            smooth: true
        }
    }

    Rectangle {
        id: tooltip
        visible: root.containsMouse && (modelData.tooltipTitle !== "" || modelData.tooltipDescription !== "" || modelData.title !== "")

        anchors.bottom: parent.top
        anchors.bottomMargin: ThemeManager.selectedTheme.dimensions.spacingMedium
        anchors.horizontalCenter: parent.horizontalCenter

        width: tooltipText.width + (ThemeManager.selectedTheme.dimensions.spacingMedium * 2)
        height: tooltipText.height + ThemeManager.selectedTheme.dimensions.spacingSmall
        z: 100

        color: ThemeManager.selectedTheme.colors.surface
        border.color: ThemeManager.selectedTheme.colors.primary
        border.width: 1
        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 4

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: (modelData.tooltipTitle || modelData.title || modelData.tooltipDescription || "")
            color: ThemeManager.selectedTheme.colors.onSurface
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

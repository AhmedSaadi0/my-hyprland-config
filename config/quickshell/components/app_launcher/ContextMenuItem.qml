// components/app_launcher/ContextMenuItem.qml
import QtQuick
import QtQuick.Layouts

import "root:/themes"

Rectangle {
    id: root

    property string iconText: ""
    property string label: ""
    property bool isHighlighted: false
    property bool showDivider: false
    property var hoverColor: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
    property var iconColor: ThemeManager.selectedTheme.colors.onSurfaceVariant

    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: showDivider ? 1 : 36
    radius: showDivider ? 0 : ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
    color: {
        if (showDivider)
            return ThemeManager.selectedTheme.colors.primary.alpha(0.1);
        if (mouseArea.containsMouse)
            return hoverColor;
        return "transparent";
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: !root.showDivider

        Text {
            text: root.iconText
            font.family: ThemeManager.selectedTheme.typography.iconFont
            font.pixelSize: 14
            color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : root.iconColor
        }

        Text {
            text: root.label
            font.pixelSize: 14
            color: ThemeManager.selectedTheme.colors.onSurface
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        visible: !root.showDivider
        onClicked: root.clicked()
    }
}

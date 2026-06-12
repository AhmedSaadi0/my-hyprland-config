// components/HeaderCard.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"
import "root:/components"

Rectangle {
    id: root

    default property alias content: contentLayout.data

    property string actionIcon: ""
    property alias actionButton: actionBtn
    signal actionClicked

    Layout.fillWidth: true
    implicitHeight: contentLayout.implicitHeight + ThemeManager.selectedTheme.dimensions.spacingMedium * 2

    color: ThemeManager.selectedTheme.colors.onSurface.alpha(0.04)
    radius: 0

    ColumnLayout {
        id: contentLayout
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: ThemeManager.selectedTheme.dimensions.spacingMedium
        }
        spacing: ThemeManager.selectedTheme.dimensions.spacingSmall
    }

    // ─── زر الأكشن بـ MButton ────────────────────────────────────
    MButton {
        id: actionBtn
        visible: root.actionIcon !== ""
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        anchors.rightMargin: 14

        width: 30
        height: 30

        iconText: root.actionIcon
        showIcon: true
        text: ""
        textPreferredWidth: 0
        iconPreferredWidth: 10

        normalBackground: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
        normalForeground: ThemeManager.selectedTheme.colors.primary
        hoveredBackground: ThemeManager.selectedTheme.colors.primary.alpha(0.5)
        downForeground: ThemeManager.selectedTheme.colors.primary
        cursorShape: Qt.PointingHandCursor

        onClicked: root.actionClicked()
    }

    // ─── خط سفلي ─────────────────────────────────────────────────
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: ThemeManager.selectedTheme.colors.onSurface.alpha(0.12)
    }
}

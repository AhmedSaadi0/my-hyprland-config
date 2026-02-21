// components/HeaderCard.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

Rectangle {
    id: root

    default property alias content: contentLayout.data

    // أيقونة اختيارية في الزاوية (للـ refresh مثلاً)
    property string actionIcon: ""
    readonly property int actionButtonSize: 40
    signal actionClicked

    Layout.fillWidth: true
    implicitHeight: contentLayout.implicitHeight + ThemeManager.selectedTheme.dimensions.spacingMedium * 2

    // خلفية طفيفة تميّزه عن الـ panel لكن بدون مبالغة
    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.04)
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

    // زر الأكشن (refresh إلخ) — يظهر فقط إذا مُرر icon
    Item {
        visible: root.actionIcon.length > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        width: root.actionButtonSize
        height: root.actionButtonSize

        Rectangle {
            anchors.centerIn: parent
            width: root.actionButtonSize - 8
            height: root.actionButtonSize - 8
            radius: (root.actionButtonSize - 8) / 2
            color: refreshArea.containsMouse ? ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.08) : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                id: actionIconText
                anchors.centerIn: parent
                text: root.actionIcon
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 24
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.7)
            }
        }

        MouseArea {
            id: refreshArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.actionClicked()
        }
    }

    // خط سفلي
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.12)
    }
}

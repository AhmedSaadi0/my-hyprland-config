// windows/leftwindow/notifications/NotificationHeader.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/components"
import "root:/themes"
import "root:/services"
import "root:/windows/leftwindow/base"

HeaderCard {
    id: headerCard

    width: parent.width

    readonly property int sidePadding: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    RowLayout {
        width: parent.width
        spacing: 2
        Layout.bottomMargin: sidePadding / 2

        Rectangle {
            visible: notifModel.count > 0
            width: countTxt.width + 15
            height: 18
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.primary
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: headerCard.sidePadding

            Text {
                id: countTxt
                anchors.centerIn: parent
                text: notifModel.count
                color: ThemeManager.selectedTheme.colors.onPrimary
                font.pixelSize: 12
                font.bold: true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        MButton {
            text: qsTr("Clear All")
            implicitHeight: 25
            implicitWidth: 80
            enabled: notifModel.count > 0
            onClicked: notifView.animateAndClearAll()

            normalBackground: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
            normalForeground: ThemeManager.selectedTheme.colors.primary
            hoveredBackground: ThemeManager.selectedTheme.colors.primary.alpha(0.5)
            downForeground: ThemeManager.selectedTheme.colors.primary
            cursorShape: Qt.PointingHandCursor

            topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
            topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / 4
            bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
            bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / 4
        }

        MButton {
            Layout.rightMargin: headerCard.sidePadding / 1.5

            text: NotifManager.dndEnabled ? "󰂛" : "󰂚"
            font: ThemeManager.selectedTheme.typography.iconFont
            implicitWidth: 35
            implicitHeight: 25
            onClicked: NotifManager.toggleDnd()

            // normalBackground: "transparent"

            ToolTip.visible: hovered
            ToolTip.text: NotifManager.dndEnabled ? "Disable DND" : "Enable DND"
            ToolTip.delay: 500

            normalBackground: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
            normalForeground: ThemeManager.selectedTheme.colors.primary
            hoveredBackground: ThemeManager.selectedTheme.colors.primary.alpha(0.5)
            downForeground: ThemeManager.selectedTheme.colors.primary
            cursorShape: Qt.PointingHandCursor

            topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / 4
            topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
            bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / 4
            bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
        }
    }
}

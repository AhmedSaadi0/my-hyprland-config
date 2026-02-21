// windows/leftwindow/notifications/NotificationHeader.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/components"
import "root:/themes"
import "root:/services"

HeaderCard {
    id: headerCard
    width: parent.width

    readonly property int sidePadding: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    RowLayout {
        width: parent.width
        spacing: 5

        Rectangle {
            visible: notifModel.count > 0
            width: countTxt.width + 10
            height: 18
            radius: 9
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
            visible: notifModel.count > 0
            onClicked: notifView.animateAndClearAll()

            normalBackground: "transparent"
        }

        MButton {
            Layout.rightMargin: headerCard.sidePadding / 1.5

            text: NotifManager.dndEnabled ? "󰂛" : "󰂚"
            font: ThemeManager.selectedTheme.typography.iconFont
            implicitWidth: 35
            implicitHeight: 25
            onClicked: NotifManager.toggleDnd()

            normalBackground: "transparent"

            ToolTip.visible: hovered
            ToolTip.text: NotifManager.dndEnabled ? "Disable DND" : "Enable DND"
            ToolTip.delay: 500
        }
    }
}

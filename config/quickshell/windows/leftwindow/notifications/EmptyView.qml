import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"

ColumnLayout {
    anchors.centerIn: parent
    spacing: 10
    visible: notifModel.count === 0
    opacity: visible ? 0.6 : 0

    property var notifModel

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    Text {
        text: "󰂚"
        font: ThemeManager.selectedTheme.typography.iconFont
        color: ThemeManager.selectedTheme.colors.onSurface
        Layout.alignment: Qt.AlignHCenter
    }
    Text {
        text: qsTr("No Notifications")
        font.pixelSize: 14
        color: ThemeManager.selectedTheme.colors.onSurface
        Layout.alignment: Qt.AlignHCenter
    }
}

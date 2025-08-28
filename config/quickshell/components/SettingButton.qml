// components/SettingButton.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property string label: ""
    property string buttonText: ""
    property string buttonIcon: ""

    signal clicked

    Label {
        text: root.label
        Layout.alignment: Qt.AlignVCenter
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 5

        MButton {
            iconText: root.buttonIcon
            text: root.buttonText
            Layout.fillWidth: true
            onClicked: root.clicked()
            textElide: Text.ElideLeft
            showTooltip: true
        }
    }
}

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
            text: root.buttonText
            iconText: root.buttonIcon
            textPreferredWidth: 4
            iconPreferredWidth: 1
            Layout.fillWidth: true
            onClicked: root.clicked()
            textElide: Text.ElideLeft
            showTooltip: true
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: root
    Layout.fillWidth: true

    property string labelText: ""
    property string inputType: "textField"
    property bool rowEnabled: true
    enabled: rowEnabled

    property alias text: inputTextField.text
    property alias checked: inputSwitch.checked

    signal inputFinished
    signal toggleChanged(bool isChecked)

    Label {
        text: root.labelText
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        opacity: root.enabled ? 1.0 : 0.5
    }

    EditableField {
        id: inputTextField
        visible: root.inputType === "textField"
        Layout.fillWidth: true
        onEditingFinished: root.inputFinished()
    }

    Switch {
        id: inputSwitch
        visible: root.inputType === "switch"
        Layout.alignment: Qt.AlignRight
        onCheckedChanged: root.toggleChanged(checked)
    }
}

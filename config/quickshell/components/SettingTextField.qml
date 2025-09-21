// components/SettingTextField.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property string label: ""
    property alias textValue: settingField.text
    spacing: 20

    property var selectedTheme

    signal editFinished(string text)
    signal accepted(string text)

    Label {
        text: root.label
        Layout.alignment: Qt.AlignVCenter
    }
    EditableField {
        id: settingField
        Layout.fillWidth: true
        selectedTheme: root.selectedTheme
        onEditingFinished: root.editFinished(text)
        onAccepted: root.accepted(text)
    }
}

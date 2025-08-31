// components/SettingTextField.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/utils/helpers.js" as Helper

RowLayout {
    id: root
    spacing: 10

    property string label: ""
    property alias textValue: settingField.text
    property var selectedTheme

    signal colorUpdated(var newColor)
    signal accepted(string text)

    Label {
        text: root.label
        Layout.alignment: Qt.AlignVCenter
    }

    EditableColorField {
        id: settingField
        Layout.fillWidth: true
        normalForeground: Helper.getAccurteTextColor(root.textValue)
        normalBackground: root.textValue
        onValidColorUpdated: root.colorUpdated(newColor)
        selectedTheme: selectedTheme
        onAccepted: root.accepted(text)
    }
}

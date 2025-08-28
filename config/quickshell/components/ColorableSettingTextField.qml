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

    signal colorUpdated(var newColor)

    Label {
        text: root.label
        Layout.alignment: Qt.AlignVCenter
    }

    EditableColorField {
        id: settingField
        Layout.fillWidth: true

        normalForeground: Helper.getAccurteTextColor(workingTheme._desktopClockColor)
        normalBackground: root.textValue

        onValidColorUpdated: root.colorUpdated(newColor)
    }
}

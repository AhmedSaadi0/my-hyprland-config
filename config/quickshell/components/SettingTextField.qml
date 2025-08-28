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

    Label {
        text: root.label
        Layout.alignment: Qt.AlignVCenter
    }
    EditableField {
        id: settingField
        Layout.fillWidth: true

        normalBackground: selectedTheme.colors.topbarBgColorV2
        normalForeground: selectedTheme.colors.topbarFgColorV2
        borderColor: selectedTheme.colors.secondary
        topLeftRadius: selectedTheme.dimensions.elementRadius
        topRightRadius: selectedTheme.dimensions.elementRadius
        bottomLeftRadius: selectedTheme.dimensions.elementRadius
        bottomRightRadius: selectedTheme.dimensions.elementRadius
    }
}

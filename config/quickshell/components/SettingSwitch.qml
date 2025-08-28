// components/SettingSwitch.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property string label: ""
    property alias isChecked: settingSwitch.checked

    Label {
        text: root.label
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
    }
    Switch {
        id: settingSwitch
        Layout.alignment: Qt.AlignRight
    }
}

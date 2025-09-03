// components/SettingSwitch.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property string label: ""
    property string tooltip: ""
    property alias isChecked: settingSwitch.checked

    ToolTip.text: root.tooltip
    ToolTip.visible: root.tooltip !== "" && root.hovered
    ToolTip.delay: 500

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

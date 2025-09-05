// components/SettingSwitch.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string tooltip: ""
    property alias isChecked: settingSwitch.checked
    property alias font: label.font

    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    ToolTip.text: root.tooltip
    ToolTip.visible: mouseArea.hovered && root.tooltip
    ToolTip.delay: 500

    RowLayout {
        id: contentLayout
        anchors.fill: parent

        Label {
            id: label
            text: root.label
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
        Switch {
            id: settingSwitch
            Layout.alignment: Qt.AlignRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.isChecked = !root.isChecked;
        }
    }
}

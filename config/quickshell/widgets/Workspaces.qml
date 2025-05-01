// Workspaces.qml
import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    property var activeIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰆈", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰆉", "󱍚", "󰺶", "󱋢", "󰤑"]
    property int underlineHeight: 2

    property var focusedId: Hyprland.focusedWorkspace.id

    property var workspaces: {
        let arr = [];
        for (let i = 1; i <= 10; i++) {
            let ws = Hyprland.workspaces[i] || dummyWorkspace(i);
            arr.push(ws);
        }
        return arr;
    }

    function dummyWorkspace(id) {
        return Qt.createQmlObject(`
            import QtQuick 2.0
            QtObject {
                property int id: ${id}
                property string name: ""
                property var clients: []
                function focus() {}
            }
        `, root);
    }

    Rectangle {
        id: container
        radius: 15
        height: parent.height
        width: row.width + 20
        color: palette.light

        // الـ Row داخل المستطيل
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5
            height: parent.height // تأخذ ارتفاع الـ container

            Repeater {
                model: workspaces
                delegate: Component {
                    Rectangle {
                        id: workspaceItem
                        width: 30
                        height: parent.height
                        color: "transparent"

                        // الخط السفلي
                        Rectangle {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            width: parent.width - 4
                            height: 2
                            color: palette.accent
                            visible: focusedId === modelData.id
                        }

                        Text {
                            anchors.centerIn: parent
                            text: focusedId === modelData.id ? root.activeIcons[modelData.id - 1] || "" : root.inActiveIcons[modelData.id - 1] || ""
                            color: focusedId === modelData.id ? palette.accent : palette.text
                            font.pixelSize: 17
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.focus()
                        }
                    }
                }
            }
        }
    }
}

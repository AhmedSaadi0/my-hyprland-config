import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

// Container styling
Rectangle {
    id: workspaceRectangle

    // Configuration properties
    property int underlineHeight: 2
    property int itemWidth: 33
    property int fontSize: 17
    property var activeIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰆈", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰆉", "󱍚", "󰺶", "󱋢", "󰤑"]

    // Hyprland interface
    property int focusedId: Hyprland.focusedWorkspace.id
    readonly property var workspaceIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    radius: 15
    height: parent.height
    width: rowLayout.implicitWidth + 20
    color: palette.light

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: workspaceRectangle.workspaceIds.reverse()

            delegate: Item {
                id: delegateItem
                implicitWidth: workspaceRectangle.itemWidth
                height: workspaceRectangle.height

                readonly property int workspaceId: modelData
                readonly property bool isFocused: workspaceId === workspaceRectangle.focusedId
                readonly property bool exists: Hyprland.workspaces.values.some(ws => ws.id === workspaceId)
                readonly property color itemColor: (isFocused || exists) ? palette.accent : palette.text.alpha(0.4)
                readonly property string icon: isFocused ? workspaceRectangle.activeIcons[workspaceId - 1] ?? "" : workspaceRectangle.inActiveIcons[workspaceId - 1] ?? ""

                // Underline indicator
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - 4
                    height: workspaceRectangle.underlineHeight
                    color: palette.accent
                    visible: delegateItem.isFocused
                }

                // Workspace icon
                Text {
                    anchors.centerIn: parent
                    text: delegateItem.icon
                    color: delegateItem.itemColor
                    font.pixelSize: workspaceRectangle.fontSize
                }

                // Click handling
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.focusWorkspace(delegateItem.workspaceId)
                }
            }
        }
    }
}

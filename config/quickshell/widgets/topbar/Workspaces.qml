import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../themes"

Rectangle {
    id: workspaceRectangle

    property int underlineHeight: 2
    property int itemWidth: 33
    property int fontSize: 17
    property var activeIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰆈", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰆉", "󱍚", "󰺶", "󱋢", "󰤑"]
    property int focusedId: Hyprland.focusedWorkspace.id
    readonly property var workspaceIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    height: parent.height
    width: rowLayout.implicitWidth + 20
    color: palette.light

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: workspaceRectangle.workspaceIds.reverse()

            delegate: MouseArea {
                id: workspaceMouseArea
                width: workspaceRectangle.itemWidth
                height: workspaceRectangle.height // Height of the main rectangle

                readonly property int workspaceId: modelData
                readonly property bool isFocused: workspaceId === workspaceRectangle.focusedId
                readonly property bool exists: Hyprland.workspaces.values.some(ws => ws.id === workspaceId)
                readonly property color itemColor: (isFocused || exists) ? palette.accent : palette.text.alpha(0.4)
                readonly property string icon: isFocused ? workspaceRectangle.activeIcons[workspaceId - 1] ?? "" : workspaceRectangle.inActiveIcons[workspaceId - 1] ?? ""
                readonly property color defaultItemColor: (isFocused || exists) ? palette.accent : palette.text.alpha(0.4)

                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Hyprland.dispatch(`workspace ${workspaceMouseArea.workspaceId}`);
                }

                // Underline indicator (now a child of the MouseArea)
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - 4
                    height: workspaceRectangle.underlineHeight
                    color: palette.accent
                    visible: workspaceMouseArea.isFocused

                    scale: workspaceMouseArea.containsMouse ? .5 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                // Workspace icon (now a child of the MouseArea)
                Text {
                    id: iconText // Give the Text element an ID
                    anchors.centerIn: parent
                    text: workspaceMouseArea.icon
                    font.pixelSize: workspaceRectangle.fontSize
                    font.family: ThemeManager.selectedTheme.typography.iconFont

                    color: workspaceMouseArea.containsMouse ? palette.active : workspaceMouseArea.defaultItemColor
                }
            }
        }
    }
}

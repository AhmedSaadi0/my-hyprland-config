import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../themes"

Rectangle {
    id: workspaceRectangle

    property int underlineHeight: 2
    property int itemWidth: 33
    property int fontSize: 18
    property var activeIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰆈", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰆉", "󱍚", "󰺶", "󱋢", "󰤑"]
    property int focusedId: Hyprland.focusedWorkspace !== null ? Hyprland.focusedWorkspace.id : 0

    readonly property var workspaceIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    readonly property var reversedWorkspaceIds: workspaceIds.slice().reverse()

    property var focusedItem: null

    height: parent.height
    width: rowLayout.implicitWidth + 20
    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    color: ThemeManager.selectedTheme.colors.topbarBgColorV1

    onFocusedIdChanged: {
        for (let i = 0; i < rowLayout.children.length; ++i) {
            if (rowLayout.children[i].workspaceId === focusedId) {
                focusedItem = rowLayout.children[i];
                return;
            }
        }
    }

    Component.onCompleted: {
        for (let i = 0; i < rowLayout.children.length; ++i) {
            if (rowLayout.children[i].workspaceId === focusedId) {
                focusedItem = rowLayout.children[i];
                return;
            }
        }
    }

    RowLayout {
        id: rowLayout
        anchors.top: parent
        spacing: 5

        Repeater {
            // --- (تحسين) ---
            // استخدام الخاصية المحسوبة مسبقًا
            model: workspaceRectangle.reversedWorkspaceIds

            delegate: MouseArea {
                id: workspaceMouseArea
                width: workspaceRectangle.itemWidth
                height: workspaceRectangle.height

                readonly property int workspaceId: modelData
                readonly property bool isFocused: workspaceId === workspaceRectangle.focusedId
                readonly property bool exists: Hyprland.workspaces.values.some(ws => ws.id === workspaceId)
                readonly property color defaultItemColor: {
                    // --- (تم التعديل) ---
                    // استخدام الربط المباشر بالثيم
                    if (isFocused || exists) {
                        ThemeManager.selectedTheme ? ThemeManager.selectedTheme.colors.primary : null;
                    } else {
                        palette.text.alpha(0.4);
                    }
                }
                readonly property string icon: isFocused ? workspaceRectangle.activeIcons[workspaceId - 1] ?? "" : workspaceRectangle.inActiveIcons[workspaceId - 1] ?? ""

                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch(`workspace ${workspaceMouseArea.workspaceId}`)

                Text {
                    id: iconText
                    anchors.centerIn: parent

                    text: workspaceMouseArea.icon

                    font.pixelSize: workspaceRectangle.fontSize
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    // --- (تم التعديل) ---
                    // استخدام الربط المباشر بالثيم
                    color: workspaceMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary : workspaceMouseArea.defaultItemColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    onTextChanged: {
                        if (exists) {
                            fadeTransition.restart();
                        }
                    }

                    SequentialAnimation {
                        id: fadeTransition
                        running: false
                        PropertyAnimation {
                            target: iconText
                            property: "opacity"
                            to: 0.5
                            duration: 150
                            easing.type: Easing.InQuad
                        }
                        PropertyAnimation {
                            target: iconText
                            property: "opacity"
                            to: 1
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: slidingIndicator

        x: workspaceRectangle.focusedItem ? rowLayout.x + workspaceRectangle.focusedItem.x : -width
        width: workspaceRectangle.focusedItem ? workspaceRectangle.focusedItem.width : 0

        height: workspaceRectangle.underlineHeight
        anchors.bottom: parent.bottom
        // --- (تم التعديل) ---
        // التأكد من استخدام الربط المباشر هنا أيضًا
        color: ThemeManager.selectedTheme.colors.primary
        radius: height / 2

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }
    }
}

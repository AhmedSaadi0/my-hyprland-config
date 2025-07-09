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

    property var focusedItem: null

    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    height: parent.height
    width: rowLayout.implicitWidth + 20
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
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            // model: workspaceRectangle.workspaceIds
            model: workspaceRectangle.workspaceIds.reverse() // For rtl layout

            delegate: MouseArea {
                id: workspaceMouseArea
                width: workspaceRectangle.itemWidth
                height: workspaceRectangle.height

                readonly property int workspaceId: modelData
                readonly property bool isFocused: workspaceId === workspaceRectangle.focusedId
                readonly property bool exists: Hyprland.workspaces.values.some(ws => ws.id === workspaceId)
                readonly property color defaultItemColor: {
                    if (isFocused) {
                        palette.accent;
                    } else if (exists) {
                        palette.accent;
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
                    color: workspaceMouseArea.containsMouse ? palette.active : workspaceMouseArea.defaultItemColor

                    // (مُحسَّن) أنميشن لتغيير اللون بسلاسة
                    Behavior on color {
                        ColorAnimation {
                            duration: 250 // تم زيادة المدة لتتوافق مع حركة المؤشر
                            easing.type: Easing.InOutQuad
                        }
                    }

                    onTextChanged: {
                        // 2. نقوم بإعادة تشغيل الأنيميشن في كل مرة
                        if (exists) {
                            fadeTransition.restart();
                        }
                    }

                    // (جديد) 3. هذا هو الأنيميشن الذي سيقوم بعملية التلاشي
                    SequentialAnimation {
                        id: fadeTransition
                        running: false // لا يعمل تلقائيًا، نحن نشغله يدويًا

                        // الخطوة الأولى: تلاشى للخارج
                        PropertyAnimation {
                            target: iconText
                            property: "opacity"
                            to: 0.5
                            duration: 150
                            easing.type: Easing.InQuad
                        }

                        // الخطوة الثالثة: تلاشى للداخل
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
        // anchors.horizontalCenterOffset: -2
        color: palette.accent
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

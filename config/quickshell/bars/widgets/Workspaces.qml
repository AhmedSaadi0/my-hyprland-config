import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "root:/themes"

Item {
    id: root

    width: mainRow.childrenRect.width + 20
    height: parent.height

    property var activeIcons: ["", "󰿣", "󰂔", "󰉋", "󱙋", "󰭹", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰻞", "󱍚", "󰺶", "󱋢", "󰤑"]

    Behavior on width {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: mainRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        // (عدد مساحات العمل)
        Repeater {
            model: activeIcons.length

            delegate: Rectangle {
                id: workspaceBox

                readonly property int wsId: index + 1

                readonly property bool hasWindows: {
                    for (let i = 0; i < 10; i++) {
                        let w = Hyprland.workspaces.values[i];
                        if (w && w.id === wsId && w.toplevels.values.length > 0)
                            return true;
                    }
                    return false;
                }

                readonly property bool isWsActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

                property bool ready: false

                height: Math.round(root.height)
                width: ready ? Math.round(contentRow.width + 8) : 0
                opacity: ready ? 1 : 0
                scale: ready ? 1 : 0.8
                clip: true

                readonly property real defaultRadius: ThemeManager.selectedTheme.dimensions.elementRadius

                topLeftRadius: index === 0 ? defaultRadius : defaultRadius / 4
                bottomLeftRadius: index === 0 ? defaultRadius : defaultRadius / 4

                topRightRadius: index === activeIcons.length - 1 ? defaultRadius : defaultRadius / 4
                bottomRightRadius: index === activeIcons.length - 1 ? defaultRadius : defaultRadius / 4

                color: isWsActive ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.topbarBgColorV1

                Component.onCompleted: {
                    ready = true;
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }

                // ===== المحتوى =====
                Row {
                    id: contentRow
                    anchors.centerIn: parent
                    spacing: 0
                    opacity: workspaceBox.width > 20 ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    // ---- أيقونات التطبيقات ----
                    Repeater {
                        model: Hyprland.toplevels

                        delegate: Item {
                            readonly property var winWs: modelData.workspace
                            readonly property bool belongsHere: winWs && winWs.id === wsId

                            width: belongsHere ? 20 : 0
                            height: 22
                            visible: width > 0
                            clip: true

                            Behavior on width {
                                NumberAnimation {
                                    duration: 350
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Image {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                sourceSize: Qt.size(32, 32)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                opacity: parent.belongsHere ? 1 : 0
                                scale: parent.belongsHere ? 1 : 0.5

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
                                }

                                source: {
                                    if (!modelData)
                                        return "";
                                    let className = modelData.appId || (modelData.lastIpcObject ? modelData.lastIpcObject.class : "");
                                    return Quickshell.iconPath(className ? className.toLowerCase() : "application-x-executable");
                                }
                            }
                        }
                    }

                    // ---- أيقونة workspace الفارغ فقط ----
                    Item {
                        visible: !workspaceBox.hasWindows
                        width: 20
                        height: 22

                        Text {
                            anchors.centerIn: parent
                            text: isWsActive ? activeIcons[wsId - 1] || "" : inActiveIcons[wsId - 1] || ""
                            font.family: ThemeManager.selectedTheme.typography.iconFont
                            font.pixelSize: 14
                            color: isWsActive ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.topbarFgColorV1
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`workspace ${wsId}`)
                }
            }
        }
    }
}

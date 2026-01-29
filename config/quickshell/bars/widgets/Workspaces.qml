import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:/themes"

Item {
    id: root

    width: mainRow.childrenRect.width + 25
    height: parent.height

    property var activeIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰭹", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰻞", "󱍚", "󰺶", "󱋢", "󰤑"]

    Behavior on width {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: mainRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: activeIcons.length

            delegate: Rectangle {
                id: workspaceBox
                readonly property int wsId: index + 1

                // --- منطق تجميع التطبيقات ---
                // وظيفة تقوم بحساب التطبيقات الفريدة وعدد تكرارها في هذه المساحة
                readonly property var groupedApps: {
                    let apps = {};
                    let toplevels = Hyprland.toplevels.values;
                    for (let i = 0; i < toplevels.length; i++) {
                        let win = toplevels[i];
                        if (win.workspace && win.workspace.id === wsId) {
                            let id = win.appId || (win.lastIpcObject ? win.lastIpcObject.class : "unknown");
                            if (!apps[id]) {
                                apps[id] = {
                                    id: id,
                                    count: 1
                                };
                            } else {
                                apps[id].count++;
                            }
                        }
                    }
                    return Object.values(apps);
                }

                readonly property bool hasWindows: groupedApps.length > 0
                readonly property bool isWsActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

                property bool ready: false

                height: Math.round(root.height)
                width: ready ? Math.round(contentRow.width + 12) : 0
                opacity: ready ? 1 : 0
                scale: ready ? 1 : 0.8
                clip: true

                readonly property real defaultRadius: ThemeManager.selectedTheme.dimensions.elementRadius
                topLeftRadius: index === 0 ? defaultRadius : defaultRadius / 4
                bottomLeftRadius: index === 0 ? defaultRadius : defaultRadius / 4
                topRightRadius: index === activeIcons.length - 1 ? defaultRadius : defaultRadius / 4
                bottomRightRadius: index === activeIcons.length - 1 ? defaultRadius : defaultRadius / 4

                color: isWsActive ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.topbarBgColorV1

                Component.onCompleted: ready = true

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

                Row {
                    id: contentRow
                    anchors.centerIn: parent
                    spacing: 6 // زيادة التباعد قليلاً ليتناسب مع العدادات
                    opacity: workspaceBox.width > 20 ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    // ---- عرض أيقونات التطبيقات المجمعة ----
                    Repeater {
                        model: workspaceBox.groupedApps

                        delegate: Item {
                            width: 22
                            height: 22

                            IconImage {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                mipmap: true
                                source: {
                                    let id = modelData.id;
                                    let entry = DesktopEntries.byId(id);
                                    let iconName = (entry && entry.icon) ? entry.icon : id;
                                    return Quickshell.iconPath(iconName, "application-x-executable");
                                }
                                asynchronous: true
                            }

                            // العداد (يظهر فقط إذا كان التطبيق مكرر)
                            Rectangle {
                                visible: modelData.count > 1
                                anchors.top: appIcon.top
                                anchors.right: appIcon.right
                                anchors.topMargin: -4
                                anchors.rightMargin: -4
                                width: 12
                                height: 12
                                radius: 6
                                color: isWsActive ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.primary
                                border.width: 1
                                border.color: workspaceBox.color

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.count
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: isWsActive ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onPrimary
                                }
                            }
                        }
                    }

                    // ---- أيقونة المساحة الفارغة ----
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

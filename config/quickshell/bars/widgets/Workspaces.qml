import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:/themes"
import "root:/config"

Item {
    id: root

    width: mainRow.childrenRect.width + 25
    height: parent.height

    property var activeIcons: App.activeWorkspacesIcons
    property var inActiveIcons: App.inActiveWorkspacesIcons

    Behavior on width {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
        // TODO: -> refresh app icon
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
                readonly property real defaultRadius: ThemeManager.selectedTheme.dimensions.elementRadius

                z: dragActive ? 100 : index
                property bool dragActive: false

                // --- منطق البيانات ---
                readonly property var groupedApps: {
                    let apps = {};
                    let toplevels = Hyprland.toplevels.values;
                    for (let i = 0; i < toplevels.length; i++) {
                        let win = toplevels[i];
                        if (win.workspace && win.workspace.id === wsId) {
                            let id = win.appId || (win.lastIpcObject ? win.lastIpcObject.class : "unknown");

                            let rawAddr = String(win.address);
                            let addr = rawAddr.startsWith("0x") ? rawAddr : "0x" + rawAddr;

                            if (!apps[id]) {
                                apps[id] = {
                                    id: id,
                                    count: 1,
                                    address: addr
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

                clip: false

                topRightRadius: index === activeIcons.length - 1 ? defaultRadius : defaultRadius / 4
                bottomRightRadius: index === activeIcons.length - 1 ? defaultRadius : defaultRadius / 4
                topLeftRadius: defaultRadius / 4
                bottomLeftRadius: defaultRadius / 4

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
                    spacing: 6
                    opacity: workspaceBox.width > 20 ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    Repeater {
                        model: workspaceBox.groupedApps

                        delegate: Item {
                            width: 22
                            height: 22

                            MouseArea {
                                id: dragArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                drag.target: tile
                                drag.axis: Drag.XAndYAxis
                                drag.smoothed: true
                                drag.threshold: 5

                                onPressed: {
                                    tile.storedAddress = modelData.address;
                                    workspaceBox.dragActive = true;
                                }

                                onClicked: {
                                    if (!isWsActive)
                                        Hyprland.dispatch(`workspace ${wsId}`);
                                }

                                onReleased: {
                                    tile.Drag.drop();
                                    tile.x = 0;
                                    tile.y = 0;
                                    workspaceBox.dragActive = false;
                                }

                                onCanceled: {
                                    workspaceBox.dragActive = false;
                                }

                                Item {
                                    id: tile
                                    width: 22
                                    height: 22

                                    property string storedAddress: ""

                                    Drag.active: dragArea.drag.active
                                    Drag.keys: ["window"]
                                    Drag.hotSpot.x: 11
                                    Drag.hotSpot.y: 11

                                    Behavior on x {
                                        enabled: !dragArea.drag.active
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                    Behavior on y {
                                        enabled: !dragArea.drag.active
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    IconImage {
                                        id: appIcon
                                        anchors.centerIn: parent
                                        width: 16
                                        height: 16
                                        mipmap: true
                                        source: {
                                            const currentTheme = ThemeManager.selectedTheme.systemSettings.themeIcons;

                                            let id = modelData.id;
                                            let entry = DesktopEntries.byId(id);
                                            let iconName = (entry && entry.icon) ? entry.icon : id;

                                            const iconPath = Quickshell.iconPath(iconName, "application-x-executable");

                                            return iconPath;
                                        }
                                        asynchronous: true
                                    }

                                    Rectangle {
                                        visible: modelData.count > 1
                                        anchors.top: appIcon.top
                                        anchors.right: appIcon.right
                                        anchors.topMargin: -4
                                        anchors.rightMargin: -4
                                        width: 12
                                        height: 12
                                        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 4
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
                        }
                    }

                    Item {
                        visible: !workspaceBox.hasWindows
                        width: 20
                        height: 22
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch(`workspace ${wsId}`)
                        }
                        Text {
                            anchors.centerIn: parent
                            text: isWsActive ? activeIcons[wsId - 1] || "" : inActiveIcons[wsId - 1] || ""
                            font.family: ThemeManager.selectedTheme.typography.iconFont
                            font.pixelSize: 14
                            color: isWsActive ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.topbarFgColorV1
                        }
                    }
                }

                DropArea {
                    anchors.fill: parent
                    keys: ["window"]

                    Rectangle {
                        anchors.fill: parent
                        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 4
                        color: "transparent"
                        border.color: parent.containsDrag ? ThemeManager.selectedTheme.colors.primary : "transparent"
                        border.width: 2
                        visible: parent.containsDrag

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: parent.border.color
                            opacity: 0.1
                        }
                    }

                    onDropped: drop => {
                        if (drop.source && drop.source.storedAddress) {
                            let winAddress = drop.source.storedAddress;

                            if (!winAddress.startsWith("0x")) {
                                winAddress = "0x" + winAddress;
                            }

                            Hyprland.dispatch(`movetoworkspacesilent ${wsId},address:${winAddress}`);
                            drop.accept();
                        } else {
                            console.warn("[Drop Fail] Source or address missing");
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`workspace ${wsId}`)
                }
            }
        }
    }
}

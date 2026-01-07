import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/themes"
import "root:/components"
import "root:/utils"
import "root:/config/EventNames.js" as Events
import "root:/config/ConstValues.js" as Consts
import "root:/config"

PanelWindow {
    id: root

    property bool isShown: false
    property int animationDuration: 600

    color: "transparent"
    visible: false

    exclusionMode: ExclusionMode.Ignore
    focusable: menus.currentIndex == Consts.APPLICATIONS_MENU_INDEX || menus.currentIndex == Consts.NETWORK_MENU_INDEX || menus.currentIndex == Consts.CLIPBOARD_MENU_INDEX || menus.currentIndex == Consts.TODO_MENU_INDEX
    implicitWidth: ThemeManager.selectedTheme.dimensions.menuWidth

    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        left: ThemeManager.selectedTheme.dimensions.leftBarWidth
        top: ThemeManager.selectedTheme.dimensions.barHeight + 10
        // bottom: 10
    }

    onIsShownChanged: {
        if (isShown) {
            if (root.visible && contentContainer.opacity > 0) {
                contentContainer.state = "visible";
                return;
            }

            contentContainer.x = -root.width;
            contentContainer.opacity = 0;

            root.visible = true;
            startOpenAnimTimer.restart();
        } else {
            startOpenAnimTimer.stop();
            contentContainer.state = "hidden";
        }
    }

    Timer {
        id: startOpenAnimTimer
        interval: 30
        repeat: false
        onTriggered: {
            if (root.isShown) {
                contentContainer.state = "visible";
            }
        }
    }

    CorneredBox {
        id: contentContainer

        width: parent.width // - 10
        height: parent.height
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        // anchors.right: parent.right

        layer.enabled: root.visible && opacity === 0
        // layer.enabled: opacity < 1.0 && opacity > 0.0
        // layer.enabled: true
        layer.smooth: true

        // radius: ThemeManager.selectedTheme.dimensions.elementRadius * 1.3
        // border.color: ThemeManager.selectedTheme.colors.primary
        // border.width: 2

        Column {
            id: col
            width: parent.width
            height: parent.height
            spacing: 10
            property int sideMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            Header {
                id: menuHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: col.sideMargin
                anchors.rightMargin: col.sideMargin
            }

            Menus {
                id: menus
                height: contentContainer.height - menuHeader.height - col.sideMargin
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: col.sideMargin
                anchors.rightMargin: col.sideMargin
            }
        }

        transformOrigin: Item.Left

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: contentContainer
                    x: 0
                    opacity: 1.0
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: contentContainer
                    x: -root.width
                    opacity: 0.0
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                ParallelAnimation {
                    NumberAnimation {
                        properties: "x"
                        duration: root.animationDuration
                        easing.type: Easing.OutExpo
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            properties: "x"
                            duration: root.animationDuration
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            properties: "opacity"
                            duration: root.animationDuration * 2
                            easing.type: Easing.InQuad
                        }
                    }

                    ScriptAction {
                        script: {
                            if (!root.isShown) {
                                root.visible = false;
                            }
                        }
                    }
                }
            }
        ]
    }

    Component.onCompleted: {
        contentContainer.x = -root.width;
        contentContainer.state = "hidden";
        root.visible = false;

        EventBus.on(Events.CLOSE_LEFTBAR, function () {
            isShown = false;
            EventBus.emit(Events.LEFT_MENU_IS_CLOSED);
        });

        EventBus.on(Events.OPEN_LEFTBAR, function (newIndex) {
            if (newIndex === -1) {
                isShown = false;
            } else {
                isShown = true;
                EventBus.emit(Events.LEFT_MENU_IS_OPENED, newIndex);
            }
        });
    }

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex === -1) {
                isShown = false;
                EventBus.emit(Events.LEFT_MENU_IS_CLOSED);
            } else {
                isShown = true;
                EventBus.emit(Events.LEFT_MENU_IS_OPENED, newIndex);
            }
        }
    }
}

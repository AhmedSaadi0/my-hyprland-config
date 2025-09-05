// pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
// import QtQuick.Layouts
import QtQuick.Effects

import "../themes"
import "../components"
import "root:/utils"
import "root:/services"
import "root:/config/EventNames.js" as Events
import "root:/config"

PanelWindow {
    id: root
    implicitWidth: 60
    implicitHeight: screen.height - ThemeManager.selectedTheme.dimensions.barHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    // exclusiveZone: 45

    anchors {
        // top: true
        left: true
        bottom: true
    }

    // --- Properties ---
    property bool panelOpen: false
    property int activeMenuIndex: LeftMenuStatus.selectedIndex

    property int notificationMenuIndex: -1

    Connections {
        target: NotifManager

        function onNotificationCountChanged() {
            if (root.notificationMenuIndex !== -1) {
                buttonGroup.model.set(root.notificationMenuIndex, {
                    "notificationCount": NotifManager.notificationCount
                });
            }
        }
    }

    Component.onCompleted: {
        for (let i = 0; i < buttonGroup.model.count; i++) {
            if (buttonGroup.model.get(i).name === "Notifications") {
                root.notificationMenuIndex = i;

                buttonGroup.model.set(i, {
                    "notificationCount": NotifManager.notificationCount
                });

                break;
            }
        }

        margins.top = -10;

        EventBus.on(Events.CLOSE_LEFTBAR, function () {
            closePanelTimer.stop();
            root.closePanel();
        });
    }

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            buttonGroup.currentIndex = newIndex;
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    CorneredBox {
        id: containerBox
        anchors.fill: parent

        bottomRightVisible: false
        topRightVisible: false

        layer.enabled: true
        layer.effect: MultiEffect {
            source: containerBox
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

        ButtonGroup {
            id: buttonGroup
            theme: ThemeManager.selectedTheme
            implicitWidth: 30
            implicitHeight: 300
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            useHand: true

            model: ListModel {
                ListElement {
                    icon: "󰨝"
                    activeIcon: "󰕮"
                    name: "Dashboard"
                }
                ListElement {
                    icon: ""
                    activeIcon: ""
                    name: "Notifications"
                    notificationCount: 0
                }
                ListElement {
                    icon: ""
                    activeIcon: "󰅟"
                    name: "Weather"
                }
                ListElement {
                    icon: ""
                    activeIcon: ""
                    name: "Monitors"
                }
                ListElement {
                    icon: "󰲝"
                    activeIcon: "󰛳"
                    name: "Network"
                }
                // ListElement {
                //     icon: "󰾰"
                //     // activeIcon: ""
                //     name: "Devices"
                // }
                ListElement {
                    icon: "󰅌"
                    activeIcon: "󰅇"
                    name: "Clipboard"
                }
                ListElement {
                    icon: "󰀻"
                    activeIcon: "󰵆"
                    name: "Applications"
                }
            }

            onCurrentIndexChanged: function () {
                const newIndex = buttonGroup.currentIndex;
                root.activeMenuIndex = newIndex;
                if (newIndex === -1) {
                    root.panelOpen = false;
                } else {
                    if (!root.panelOpen) {
                        root.panelOpen = true;
                    }
                }
                LeftMenuStatus.changeIndex(newIndex);
            }
        }
    }

    function closePanel() {
        closePanelTimer.start();
    }

    Timer {
        id: closePanelTimer
        interval: 600
        repeat: false
        onTriggered: LeftMenuStatus.changeIndex(-1)
    }
}

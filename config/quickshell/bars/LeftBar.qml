// pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
// import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland

import "../themes"
import "../components"
import "root:/utils"
import "root:/services"
import "root:/config/EventNames.js" as Events
import "root:/config"

PanelWindow {
    id: root

    implicitWidth: 40
    // implicitHeight: screen.height - ThemeManager.selectedTheme.dimensions.barHeight

    color: ThemeManager.selectedTheme.colors.topbarColor
    exclusionMode: ExclusionMode.Ignore

    // WlrLayershell.layer: WlrLayer.Overlay

    // exclusiveZone: 45

    anchors {
        top: true
        left: true
        bottom: true
    }

    margins.top: ThemeManager.selectedTheme.dimensions.barHeight

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

        EventBus.on(Events.CLOSE_LEFTBAR, function () {
            closePanel();
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

    ButtonGroup {
        id: buttonGroup
        theme: ThemeManager.selectedTheme
        implicitWidth: 30
        implicitHeight: 900
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        useHand: true

        layer.enabled: true
        layer.effect: MultiEffect {
            source: buttonGroup
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

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

    // ButtonGroup {
    //     id: bottomButtonGroup
    //     theme: ThemeManager.selectedTheme
    //     implicitWidth: 30
    //     implicitHeight: 100 
    //     anchors.left: parent.left
    //     anchors.bottom: parent.bottom 
    //     anchors.leftMargin: 5
    //     anchors.rightMargin: 5
    //     // anchors.bottomMargin: 20 
    //     useHand: true
    //
    //     model: ListModel {
    //     }
    //
    //     onCurrentIndexChanged: {
    //         const newIndex = bottomButtonGroup.currentIndex ;
    //         root.activeMenuIndex = newIndex;
    //         if (newIndex === -1) {
    //             root.panelOpen = false;
    //         } else {
    //             if (!root.panelOpen) {
    //                 root.panelOpen = true;
    //             }
    //         }
    //         LeftMenuStatus.changeIndex(newIndex + 7);
    //     }
    // }

    function closePanel() {
        if (closePanelTimer !== undefined) {
            closePanelTimer.start();
        } else {
            LeftMenuStatus.changeIndex(-1);
        }
    }

    Timer {
        id: closePanelTimer
        interval: 600
        repeat: false
        onTriggered: LeftMenuStatus.changeIndex(-1)
    }
}

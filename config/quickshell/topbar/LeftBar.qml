// pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
// import QtQuick.Layouts
import QtQuick.Effects

import "../themes"
import "../components"
import "root:/utils"

PanelWindow {
    id: root

    // --- Properties ---
    property bool panelOpen: false
    property int activeMenuIndex: LeftMenuStatus.selectedIndex
    exclusiveZone: 45

    implicitWidth: 60
    implicitHeight: screen.height - ThemeManager.selectedTheme.dimensions.barHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

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

    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        top: -10
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
            // anchors.fill: parent

            implicitWidth: 30
            implicitHeight: 300

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            // Pass the model data to the group
            model: ListModel {
                ListElement {
                    icon: "󰨝"
                    name: "Dashboard"
                }
                ListElement {
                    icon: "󰂞"
                    name: "Notifications"
                }
                ListElement {
                    text: "Weather"
                    icon: "󰨹"
                }
                ListElement {
                    text: "Monitors"
                    icon: ""
                }
                ListElement {
                    text: "Network"
                    icon: ""
                }
            }

            // Connect the group's state to the panel's state

            // React to clicks within the group
            onCurrentIndexChanged: function () {
                const newIndex = buttonGroup.currentIndex;
                root.activeMenuIndex = newIndex;
                if (newIndex === -1) {
                    root.panelOpen = false;
                } else {
                    // Check if it was already open with the same menu
                    // to prevent re-triggering animations.
                    if (!root.panelOpen) {
                        root.panelOpen = true;
                    }
                }
                LeftMenuStatus.changeIndex(newIndex);
            }
        }
    }
}

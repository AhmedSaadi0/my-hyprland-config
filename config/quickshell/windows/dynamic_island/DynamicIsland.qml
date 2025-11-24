// windows/dynamic_island/DynamicIsland.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:/themes"
import "root:/components"
import "root:/services"
import "root:/config"
import "./widgets"

PanelWindow {
    id: dynamicIsland

    color: "transparent"
    implicitHeight: 400
    exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        left: true
        right: true
    }
    mask: Region {
        item: islandRect
    }

    property string stateMode: "idle"
    property string activeTab: "weather"

    property int barFullHeight: ThemeManager.selectedTheme.dimensions.barHeight
    property int idleWidgetHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    property int centeredTopMargin: (barFullHeight - idleWidgetHeight) / 2
    property int droppedTopMargin: barFullHeight + 10

    property var activePlayer: MediaController.activePlayer
    property int playersCount: MediaController.playersCount

    // property int activePlayerIndex: 0
    // property var playersArray: Mpris.players.values

    // property bool hasActivePlayer: activePlayer !== null

    property bool isHovered: false
    property bool isInteracting: false

    function cyclePlayers() {
        MediaController.cyclePlayers();
    }

    function expand(tabName) {
        activeTab = tabName;
        stateMode = "expanded";
    }

    function collapse() {
        stateMode = "idle";
    }

    NibrasShellShortcut {
        id: toggleMediaIsland
        name: "toggleMediaIsland"
        // enabled: dynamicIsland.isPrimaryScreen
        onPressed: {
            if (activeTab === "media" && stateMode === "expanded") {
                collapse();
            } else {
                expand("media");
            }
        }
    }

    NibrasShellShortcut {
        id: toggleWeatherIsland
        name: "toggleWeatherIsland"
        onPressed: {
            if (activeTab === "weather" && stateMode === "expanded") {
                collapse();
            } else {
                expand("weather");
            }
        }
    }

    Rectangle {
        id: islandRect

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: "transparent"
        clip: true

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: ThemeManager.selectedTheme.colors.primary
            }
            GradientStop {
                position: 1.0
                color: ThemeManager.selectedTheme.colors.secondary
            }
        }

        Behavior on width {
            enabled: stateMode === "idle"
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        MouseArea {
            id: islandMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: false

            onEntered: dynamicIsland.isHovered = true
            onExited: dynamicIsland.isHovered = false
        }

        IdleBar {
            id: idleBar
            anchors.fill: parent

            opacity: stateMode === "idle" ? 1 : 0
            visible: opacity > 0

            isListening: stateMode === "idle"

            activePlayer: dynamicIsland.activePlayer
            onRequestExpand: mode => dynamicIsland.expand(mode)
        }

        ExpandedContainer {
            id: expandedContainer
            anchors.fill: parent
            opacity: stateMode === "expanded" ? 1 : 0
            visible: opacity > 0

            currentTab: dynamicIsland.activeTab

            playersCount: dynamicIsland.playersCount

            onTabChanged: newTab => dynamicIsland.activeTab = newTab
            onCloseRequested: dynamicIsland.collapse()
            onSwitchPlayerRequested: dynamicIsland.cyclePlayers()
        }

        state: stateMode

        states: [
            State {
                name: "idle"
                PropertyChanges {
                    target: islandRect
                    height: dynamicIsland.idleWidgetHeight
                    anchors.topMargin: dynamicIsland.centeredTopMargin

                    width: idleBar.clockTextWidth + 40

                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                }
            },
            State {
                name: "expanded"
                PropertyChanges {
                    target: islandRect
                    height: expandedContainer.implicitHeight
                    anchors.topMargin: dynamicIsland.droppedTopMargin

                    width: 420
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                }
            }
        ]

        transitions: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "anchors.topMargin"
                    duration: 400
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    properties: "width, height"
                    duration: 450
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.7
                }
                NumberAnimation {
                    property: "radius"
                    duration: 400
                }
            }
        }
    }
}

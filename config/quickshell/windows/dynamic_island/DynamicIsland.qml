import Quickshell
import QtQuick
import QtQuick.Layouts 1.15
import Quickshell.Services.Mpris

import "root:/themes"
import "root:/components"
import "root:/services"
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

    property int activePlayerIndex: 0
    property var playersArray: Mpris.players.values

    property var activePlayer: {
        if (playersArray.length === 0)
            return null;
        // حماية الاندكس
        if (activePlayerIndex >= playersArray.length)
            activePlayerIndex = 0;
        return playersArray[activePlayerIndex];
    }

    property bool hasActivePlayer: activePlayer !== null

    property bool isHovered: false
    property bool isInteracting: false

    function cyclePlayers() {
        if (playersArray.length > 1) {
            activePlayerIndex = (activePlayerIndex + 1) % playersArray.length;
        }
    }

    function expand(tabName) {
        activeTab = tabName;
        stateMode = "expanded";
    }

    function collapse() {
        stateMode = "idle";
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
            activePlayer: dynamicIsland.activePlayer

            playersCount: dynamicIsland.playersArray.length

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

                    width: 400
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

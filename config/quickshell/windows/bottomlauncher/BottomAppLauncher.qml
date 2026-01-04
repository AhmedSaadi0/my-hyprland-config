// windows/bottomlauncher/BottomAppLauncher.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events

PanelWindow {
    id: root

    property bool isShown: false

    color: "transparent"
    visible: false
    focusable: true

    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 600

    mask: Region {
        item: contentContainer
    }

    margins {
        bottom: 20
    }

    // Keyboard shortcut to toggle the launcher
    NibrasShellShortcut {
        id: toggleLauncherShortcut
        name: "toggleBottomLauncher"
        onPressed: root.toggle()
    }

    // Toggle visibility
    function toggle() {
        isShown = !isShown;
    }

    function show() {
        isShown = true;
    }

    function hide() {
        isShown = false;
    }

    onIsShownChanged: {
        if (isShown) {
            if (root.visible && contentContainer.opacity > 0) {
                contentContainer.state = "visible";
                return;
            }

            contentContainer.y = 50;
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
                launcherContent.gainFocus();
            }
        }
    }

    // Close when clicking outside
    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
        z: -1
    }

    Rectangle {
        id: contentContainer

        width: App.bottomLauncherWidth
        height: parent.height - 10

        anchors.horizontalCenter: parent.horizontalCenter

        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 1.5
        color: ThemeManager.selectedTheme.colors.leftMenuBgColorV1
        border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
        border.width: 1

        layer.enabled: root.visible && opacity < 1
        layer.smooth: true

        // Shadow effect
        Rectangle {
            id: shadowRect
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            radius: parent.radius + 2
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.3)
            border.width: 4
            visible: false
        }

        LauncherContent {
            id: launcherContent
            anchors.fill: parent
            anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            onAppLaunched: {
                root.hide();
            }
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: contentContainer
                    y: 0
                    opacity: 1.0
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: contentContainer
                    y: 150
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
                        properties: "y"
                        duration: 350
                        easing.type: Easing.OutExpo
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 200
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
                            properties: "y"
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            properties: "opacity"
                            duration: 250
                            easing.type: Easing.InQuad
                        }
                    }
                    ScriptAction {
                        script: root.visible = false
                    }
                }
            }
        ]
    }
}

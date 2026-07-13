// windows/bottomlauncher/BottomLauncher.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "root:/components/app_launcher"
import "root:/config"
import "root:/config/EventNames.js" as Events

PanelWindow {
    id: root

    property bool isShown: false
    property real dockWidth: App.bottomLauncherWidth
    readonly property int dockHeight: App.dockIconSize + 32

    color: "transparent"
    visible: false
    focusable: true

    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 600 + dockHeight

    mask: Region {
        item: contentContainer
    }

    margins {
        bottom: (App.hasWindowsOnWorkspace ? 0 : 12) + 12 + dockHeight
    }

    NibrasShellShortcut {
        id: toggleLauncherShortcut
        name: "toggleBottomLauncher"
        onPressed: root.toggle()
    }

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
            EventBus.emit(Events.BOTTOM_LAUNCHER_OPENED);
            if (root.visible && contentContainer.opacity > 0) {
                contentContainer.state = "visible";
                return;
            }

            contentContainer.y = root.height;
            contentContainer.opacity = 0;

            root.visible = true;
            startOpenAnimTimer.restart();
        } else {
            EventBus.emit(Events.BOTTOM_LAUNCHER_CLOSED);
            startOpenAnimTimer.stop();
            contentContainer.state = "hidden";
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.DOCK_WIDTH_CHANGED, w => {
            root.dockWidth = w;
        }, root);
    }

    Timer {
        id: startOpenAnimTimer
        interval: 0
        repeat: false
        onTriggered: {
            if (root.isShown) {
                contentContainer.state = "visible";
                launcherContent.baseLauncher.doGainFocus();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
        z: -1
    }

    Rectangle {
        id: contentContainer

        width: Math.max(root.dockWidth, App.bottomLauncherWidth)
        height: parent.height - 10

        anchors.horizontalCenter: parent.horizontalCenter

        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 1.5
        color: ThemeManager.selectedTheme.colors.surface
        border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.5)
        border.width: 2

        layer.enabled: root.visible && opacity < 1
        layer.smooth: true

        Rectangle {
            id: shadowRect
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            radius: parent.radius + 2
            color: "transparent"
            border.color: Qt.darker(ThemeManager.selectedTheme.colors.surface, 1.4).alpha(0.3)
            border.width: 4
            visible: false
        }

        AppLauncherBase {
            id: launcherContent
            anchors.fill: parent
            anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            onAppLaunchedCallback: function () {
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
                    y: root.height
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
                        target: contentContainer
                        property: "y"
                        duration: 280
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: contentContainer
                        property: "opacity"
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
                            property: "y"
                            duration: 200
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            property: "opacity"
                            duration: 160
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

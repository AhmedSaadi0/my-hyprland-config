// windows/bottomlauncher/BottomLauncher.qml
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
        interval: 30
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
        color: ThemeManager.selectedTheme.colors.surfaceContainer
        border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
        border.width: 1

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
                    // حركة فيزيائية مرنة وسريعة لصعود حاوية التطبيقات
                    SpringAnimation {
                        target: contentContainer
                        properties: "y"
                        spring: 4.5        // زيادة صلابة وقوة النابض لتسريع السحب (السابق: 3.0)
                        damping: 0.62      // امتصاص متوازن يضمن ارتداداً هلامياً خفيفاً وسريع الاستقرار
                        mass: 0.4          // تقليل الكتلة لجعل الجسم خفيفاً ويتسارع فوراً (السابق: 0.8)
                        epsilon: 0.1       // إنهاء الأنيميشن مبكراً فور الاقتراب لتجنب التباطؤ الدقيق في النهاية
                    }
                    NumberAnimation {
                        target: contentContainer
                        properties: "opacity"
                        duration: 180      // تقليص المدة لتتزامن مع سرعة الصعود الفيزيائي الجديدة (السابق: 250)
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
                            duration: 180  // تسريع حركة النزول عند الإغلاق (السابق: 250)
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            properties: "opacity"
                            duration: 150  // تسريع اختفاء الشفافية لتبدو الاستجابة فورية (السابق: 200)
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

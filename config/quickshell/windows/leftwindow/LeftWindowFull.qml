import QtQuick
import Quickshell
import "../../themes"
import "../../components"

PanelWindow {
    id: root

    property bool isShown: false
    property var menuSelectorRef: menus

    width: ThemeManager.selectedTheme.dimensions.menuWidth
    color: "transparent"

    anchors {
        top: true
        left: true
        bottom: true
    }

    Rectangle {
        id: contentContainer
        width: parent.width
        height: parent.height
        color: ThemeManager.selectedTheme.colors.topbarColor
        opacity: 0.0
        scale: 0.98
        x: -50

        Header {
            id: menuHeader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MenuSelectorBar {
            id: menus
            anchors {
                top: menuHeader.bottom
                left: contentContainer.left
                right: contentContainer.right
                bottom: contentContainer.bottom
                leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 1.6
            }
        }
        transformOrigin: Item.Center

        states: [
            State {
                name: "SHOWN"
                when: root.isShown
                PropertyChanges {
                    target: contentContainer
                    x: 0
                    opacity: 1.0
                    scale: 1.0
                }
            },
            State {
                name: "HIDDEN"
                when: !root.isShown
                PropertyChanges {
                    target: contentContainer
                    x: -contentContainer.width  // يخرج من الشاشة كلياً
                    opacity: 0.0
                    scale: 0.95  // تصغير خفيف
                }
            }
        ]

        transitions: [
            Transition {
                from: "HIDDEN"
                to: "SHOWN"
                ParallelAnimation {
                    NumberAnimation {
                        properties: "x"
                        duration: 500
                        easing.type: Easing.OutExpo  // نفس smoothOut
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 420
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        properties: "scale"
                        duration: 480
                        easing.type: Easing.OutExpo
                    }
                }
            },
            Transition {
                from: "SHOWN"
                to: "HIDDEN"
                ParallelAnimation {
                    NumberAnimation {
                        properties: "x"
                        duration: 300
                        easing.type: Easing.InCubic  // نفس smoothIn
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 280
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        properties: "scale"
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                }
            }
        ]
    }

    // عند التغيير في isShown، نهيّئ الظهور أو بدء الإخفاء المؤجل
    onIsShownChanged: {
        if (isShown) {
            root.visible = true;
        } else {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 300
        repeat: false
        onTriggered: root.visible = false
    }

    Component.onCompleted: {
        if (!isShown) {
            root.visible = false;
        }
    }

    function open() {
        isShown = true;
    }
    function close() {
        isShown = false;
    }
}

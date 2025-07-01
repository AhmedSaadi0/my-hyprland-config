import QtQuick
import Quickshell
import "../../themes"
// import QtQuick.Controls.Material

import "../../components"

PanelWindow {
    id: root

    property bool isShown: false
    property var menuSelectorRef: menus

    // implicitWidth: ThemeManager.selectedTheme.dimensions.menuWidth
    implicitWidth: 40
    color: "transparent"
    // color: ThemeManager.selectedTheme.colors.topbarColor
    visible: true

    anchors {
        top: true
        left: true
        bottom: true
    }

    Rectangle {
        id: iconsBar
        color: ThemeManager.selectedTheme.colors.topbarColor
        implicitWidth: 40
        height: parent.height
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        MButton {
            id: dashboardIcon
            text: "󰨝"
            normalBackground: "transparent"
            height: 30

            font {
                family: ThemeManager.selectedTheme.typography.iconFont
                pixelSize: 15
            }

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right

                topMargin: 20
                leftMargin: 5
                rightMargin: 5
            }
        }

        MButton {
            id: notificationsIcon
            text: "󰂞"
            normalBackground: "transparent"
            height: 30

            font {
                family: ThemeManager.selectedTheme.typography.iconFont
                pixelSize: 15
            }

            anchors {
                top: dashboardIcon.bottom
                left: parent.left
                right: parent.right

                topMargin: 10
                leftMargin: 5
                rightMargin: 5
            }
        }
    }

    Rectangle {
        id: contentContainer
        // width: ThemeManager.selectedTheme.dimensions.menuWidth
        implicitWidth: ThemeManager.selectedTheme.dimensions.menuWidth
        height: parent.height
        color: ThemeManager.selectedTheme.colors.topbarColor

        opacity: 0.0
        scale: 0.98
        x: -50

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

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
                        duration: 400
                        easing.type: Easing.InCubic  // نفس smoothIn
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 280
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        properties: "scale"
                        duration: 400
                        easing.type: Easing.InCubic
                    }
                }
            }
        ]
    }

    // عند التغيير في isShown، نهيّئ الظهور أو بدء الإخفاء المؤجل
    onIsShownChanged: {
        if (isShown) {
            root.implicitWidth = ThemeManager.selectedTheme.dimensions.menuWidth + 40;
        } else {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 400
        repeat: false
        onTriggered: root.implicitWidth = 40
    }

    Component.onCompleted: {
        if (!isShown) {
            root.implicitWidth = 40;
        }
    }

    function open() {
        isShown = true;
    }

    function close() {
        isShown = false;
    }
}

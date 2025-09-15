import QtQuick
import Quickshell
// import QtQuick.Layouts

import "root:/themes"
import "root:/components"
import "root:/utils"
import "root:/config/EventNames.js" as Events
import "root:/config"

PanelWindow {
    id: root

    property bool isShown: false
    property var menuSelectorRef: menus

    implicitWidth: ThemeManager.selectedTheme.dimensions.menuWidth
    implicitHeight: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight

    exclusiveZone: ThemeManager.selectedTheme.dimensions.menuWidth - 40

    color: "transparent"
    visible: false

    focusable: menus.currentIndex == 0 || menus.currentIndex == 6
    // exclusionMode: ExclusionMode.Ignore
    // exclusionMode: ExclusionMode.Auto

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex === -1) {
                root.close();
            } else {
                root.open();
            }
        }
    }

    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        left: 40
        // top: -10
    }

    CorneredBox {
        id: contentContainer
        implicitWidth: parent.width
        implicitHeight: parent.height
        // color: "#000000"

        // opacity: 1.0
        // scale: 0.98
        x: -50

        layer.enabled: true
        layer.effect: Shadow {}

        Column {
            id: col
            width: parent.width
            height: root.implicitHeight

            spacing: 10
            // anchors.fill: parent

            property int sideMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            Header {
                id: menuHeader

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: col.sideMargin
                anchors.rightMargin: col.sideMargin
            }

            Menus {
                id: menus
                height: contentContainer.height - menuHeader.height - col.sideMargin

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: col.sideMargin
                anchors.rightMargin: col.sideMargin
            }
        }
        // ColumnLayout {
        //     id: contentCo
        //     width: parent.width - 25
        //     height: root.implicitHeight
        //
        //     Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        //     Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        //
        //     // leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin + 100
        //

        // }

        transformOrigin: Item.Left

        states: [
            State {
                name: "SHOWN"
                when: root.isShown
                PropertyChanges {
                    target: contentContainer
                    x: 0
                    // opacity: 1.0
                    // scale: 1.0
                }
            },
            State {
                name: "HIDDEN"
                when: !root.isShown
                PropertyChanges {
                    target: contentContainer
                    x: -contentContainer.width  // يخرج من الشاشة كلياً
                    // opacity: 0.0
                    // scale: 0.95  // تصغير خفيف
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
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                    // NumberAnimation {
                    //     properties: "opacity"
                    //     duration: 300
                    //     easing.type: Easing.InOutQuad
                    // }
                    // NumberAnimation {
                    //     properties: "scale"
                    //     duration: 560
                    //     easing.type: Easing.OutBack
                    // }
                }
            },
            Transition {
                from: "SHOWN"
                to: "HIDDEN"
                ParallelAnimation {
                    NumberAnimation {
                        properties: "x"
                        duration: 400
                        easing.type: Easing.InExpo
                    }
                    // NumberAnimation {
                    //     properties: "opacity"
                    //     duration: 900
                    //     easing.type: Easing.InQuad
                    // }
                    // NumberAnimation {
                    //     properties: "scale"
                    //     duration: 360
                    //     easing.type: Easing.InCubic
                    // }
                }
            }
        ]
    }

    // عند التغيير في isShown، نهيّئ الظهور أو بدء الإخفاء المؤجل
    onIsShownChanged: {
        if (isShown) {
            root.visible = true;
            hideTimer.stop();
        } else {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 500
        repeat: false
        onTriggered: root.visible = false
    }

    Component.onCompleted: {
        if (!isShown) {
            root.visible = false;
        }

        EventBus.on(Events.CLOSE_LEFTBAR, function () {
            // root.close();
            isShown = false;
        });

        EventBus.on(Events.OPEN_LEFTBAR, function () {
            isShown = true;
        // root.open();
        });
    }

    function open() {
        EventBus.emit(Events.OPEN_LEFTBAR);
    }
    function close() {
        EventBus.emit(Events.CLOSE_LEFTBAR);
    }
}

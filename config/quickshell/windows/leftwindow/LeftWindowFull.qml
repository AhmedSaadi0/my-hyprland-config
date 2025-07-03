import QtQuick
import Quickshell
import QtQuick.Layouts
import "../../themes"
import "../../components"

PanelWindow {
    id: root

    property bool isShown: false
    property var menuSelectorRef: menus

    implicitWidth: ThemeManager.selectedTheme.dimensions.menuWidth + 50
    implicitHeight: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight
    color: "transparent"
    visible: false

    exclusionMode: ExclusionMode.Ignore

    anchors {
        // top: true
        left: true
        bottom: true
    }

    // Rectangle {
    CorneredBox {
        id: contentContainer
        width: parent.width - 25
        height: parent.height
        // color: "#000000"

        opacity: 1.0
        // scale: 0.98
        x: -50

        layer.enabled: true
        layer.effect: Shadow {}

        Column {
            id: col
            width: parent.width - 25
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

            MenuSelectorBar {
                id: menus

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
                        duration: 500
                        easing.type: Easing.OutExpo
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
                        duration: 500
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
        } else {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 800
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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/services"
import "root:/themes"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    // Header
    ClipboardHeader {
        onClearAllClicked: listView.animateAndClearAll()
    }

    // List
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        rightPadding: ScrollBar.vertical.visible ? ScrollBar.vertical.width : 0

        ListView {
            id: listView
            anchors.fill: parent
            spacing: 12
            topMargin: 5
            bottomMargin: 10

            model: ClipboardService.model
            cacheBuffer: 2000

            property real pullOffset: 0
            property real shockOffset: 0
            property bool userIsDragging: false

            function triggerSway() {
                swayAnim.restart();
            }
            function animateAndClearAll() {
                if (listView.count > 0) {
                    ClipboardService.wipe();
                    // clearAllSequence.start();
                }
            }

            Behavior on pullOffset {
                enabled: !listView.userIsDragging
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            SequentialAnimation {
                id: swayAnim
                NumberAnimation {
                    target: listView
                    property: "shockOffset"
                    to: 7
                    duration: 150
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: listView
                    property: "shockOffset"
                    to: 0
                    duration: 600
                    easing.type: Easing.OutElastic
                    easing.period: 0.8
                    easing.amplitude: 0.5
                }
            }
            SequentialAnimation {
                id: clearAllSequence
                ParallelAnimation {
                    NumberAnimation {
                        target: listView
                        property: "pullOffset"
                        to: 300
                        duration: 300
                        easing.type: Easing.InBack
                        easing.overshoot: 1.2
                    }
                    NumberAnimation {
                        target: listView
                        property: "opacity"
                        to: 0
                        duration: 250
                    }
                }
                // ScriptAction {
                //     // script: ClipboardService.wipe()
                // }
                PropertyAction {
                    target: listView
                    property: "pullOffset"
                    value: 0
                }
                PropertyAction {
                    target: listView
                    property: "opacity"
                    value: 1
                }
            }

            add: Transition {
                NumberAnimation {
                    property: "height"
                    from: 0
                    to: 50
                    duration: 300
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                }
            }
            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 400
                    easing.type: Easing.OutQuart
                }
            }
            remove: Transition {
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 200
                        }
                        NumberAnimation {
                            property: "x"
                            to: 100
                            duration: 250
                            easing.type: Easing.InQuad
                        }
                    }
                    NumberAnimation {
                        property: "height"
                        to: 0
                        duration: 300
                        easing.type: Easing.InOutQuart
                    }
                }
            }

            // ----------------------------------------------------
            // DELEGATE
            // ----------------------------------------------------
            delegate: ClipboardItem {}
        }
    }

    Component.onCompleted: {
        ClipboardService.refresh();
        EventBus.on(Events.LEFT_MENU_IS_OPENED, function (idx) {
            if (idx === 5)
                ClipboardService.refresh();
        });
    }
}

// windows/leftwindow/notifications/NotificationsList.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/services"
import "root:/themes"
import "root:/components"
import "root:/components/notifications"
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Notifications")
    menuIcon: "󰂚"
    showPrimaryAction: false

    readonly property int sidePadding: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    // ============================================================
    // Data & Connections
    // ============================================================
    ListModel {
        id: notifModel
    }

    Connections {
        target: NotifManager
        function onNotificationReceived(smartNotifObject) {
            notifModel.insert(0, {
                "smartNotif": smartNotifObject
            });
        }
        function onNotificationClosed(smartNotifObject) {
            for (let i = 0; i < notifModel.count; ++i) {
                if (notifModel.get(i).smartNotif === smartNotifObject) {
                    if (notifView)
                        notifView.triggerSway();
                    notifModel.remove(i);
                    break;
                }
            }
        }
    }

    // ============================================================
    // المحتوى
    // ============================================================

    // Header Actions
    headerContent: NotificationHeader {
        id: headerCard
    }

    // Content Area
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height - root.topAppBarHeight - headerCard.implicitHeight - root.sidePadding - 5
        Layout.topMargin: root.sidePadding - 3

        // Empty State
        EmptyView {
            notifModel: notifModel
        }

        // Notification List
        ScrollView {
            anchors.fill: parent
            anchors.leftMargin: root.sidePadding
            anchors.rightMargin: root.sidePadding
            visible: notifModel.count > 0
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: notifView
                width: parent.width
                model: notifModel
                spacing: 12
                bottomMargin: 3
                cacheBuffer: 2000

                property real pullStartDistance: 5
                property real recoilRightDistance: 15
                property real shockOffset: 0
                property real pullOffset: 0
                property bool userIsDragging: false

                function triggerSway() {
                    swayAnim.restart();
                }
                function animateAndClearAll() {
                    if (notifModel.count > 0)
                        clearAllSequence.start();
                }

                Behavior on pullOffset {
                    enabled: !notifView.userIsDragging
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                SequentialAnimation {
                    id: clearAllSequence
                    ParallelAnimation {
                        NumberAnimation {
                            target: notifView
                            property: "pullOffset"
                            to: 200
                            duration: 300
                            easing.type: Easing.InBack
                            easing.overshoot: 1.2
                        }
                        NumberAnimation {
                            target: notifView
                            property: "opacity"
                            to: 0
                            duration: 250
                        }
                    }
                    ScriptAction {
                        script: NotifManager.clearAllNotifs()
                    }
                    PropertyAction {
                        target: notifView
                        property: "pullOffset"
                        value: 0
                    }
                    PropertyAction {
                        target: notifView
                        property: "opacity"
                        value: 1
                    }
                }

                SequentialAnimation {
                    id: swayAnim
                    NumberAnimation {
                        target: notifView
                        property: "shockOffset"
                        to: notifView.recoilRightDistance
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: notifView
                        property: "shockOffset"
                        to: 0
                        duration: 600
                        easing.type: Easing.OutElastic
                        easing.period: 0.8
                        easing.amplitude: 0.5
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 600
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
                            duration: 450
                            easing.type: Easing.InOutQuart
                        }
                    }
                }

                delegate: Item {
                    id: wrapper
                    width: notifView.width
                    height: actualItem.implicitHeight
                    transform: [
                        Translate {
                            x: notifView.pullOffset + notifView.shockOffset
                        }
                    ]

                    Item {
                        id: swipeContainer
                        width: parent.width
                        height: actualItem.implicitHeight

                        Behavior on x {
                            enabled: !dragArea.drag.active
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.0
                            }
                        }

                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            drag.target: swipeContainer
                            drag.axis: Drag.XAxis
                            drag.minimumX: 0
                            drag.maximumX: 600
                            drag.filterChildren: true

                            onPressed: notifView.userIsDragging = true
                            onPositionChanged: {
                                if (drag.active) {
                                    var tension = Math.max(0, swipeContainer.x / 12);
                                    notifView.pullOffset = Math.min(tension, 30);
                                }
                            }
                            onReleased: {
                                notifView.userIsDragging = false;
                                if (swipeContainer.x > 120) {
                                    notifView.pullOffset = 0;
                                    swipeContainer.x = 600;
                                    if (model.smartNotif)
                                        model.smartNotif.notification.dismiss();
                                } else {
                                    swipeContainer.x = 0;
                                    notifView.pullOffset = 0;
                                }
                            }
                        }

                        NotificationItem {
                            id: actualItem
                            width: swipeContainer.width
                            notification: model.smartNotif
                            theme: ThemeManager.selectedTheme
                            opacity: 1 - (swipeContainer.x / 300)
                            scale: 0.85

                            transform: [
                                Translate {
                                    id: entryTranslate
                                    y: -30
                                }
                            ]

                            ParallelAnimation {
                                id: entryAnim
                                running: true
                                NumberAnimation {
                                    target: actualItem
                                    property: "opacity"
                                    to: 1
                                    duration: 250
                                    easing.type: Easing.Linear
                                }
                                NumberAnimation {
                                    target: actualItem
                                    property: "scale"
                                    to: 1
                                    duration: 550
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.0
                                }
                                NumberAnimation {
                                    target: entryTranslate
                                    property: "y"
                                    to: 0
                                    duration: 550
                                    easing.type: Easing.OutQuint
                                }
                            }

                            Timer {
                                interval: 300
                                running: true
                                repeat: false
                                onTriggered: actualItem.opacity = Qt.binding(() => 1 - (swipeContainer.x / 300))
                            }

                            onDismissPressedChanged: {
                                if (!dragArea.drag.active)
                                    notifView.pullOffset = dismissPressed ? notifView.pullStartDistance : 0;
                            }
                            onDismissClicked: {
                                notifView.pullOffset = 0;
                                if (model.smartNotif)
                                    model.smartNotif.notification.dismiss();
                            }
                            onActionInvoked: index => {
                                if (model.smartNotif)
                                    model.smartNotif.invokeAction(index);
                            }
                        }
                    }
                }
            }
        }
    }
}

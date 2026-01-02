import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/services"
import "root:/themes"
import "root:/components"
import "root:/components/notifications"

Item {
    id: root

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
    // Main Layout
    // ============================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 5
            spacing: 5

            Text {
                text: qsTr("Notifications")
                font.bold: true
                font.pixelSize: 16
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                visible: notifModel.count > 0
                width: countTxt.width + 10
                height: 18
                radius: 9
                color: ThemeManager.selectedTheme.colors.primary
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: countTxt
                    anchors.centerIn: parent
                    text: notifModel.count
                    color: ThemeManager.selectedTheme.colors.onPrimary
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            MButton {
                text: qsTr("Clear All")
                implicitHeight: 30
                implicitWidth: 80
                visible: notifModel.count > 0
                onClicked: notifView.animateAndClearAll()
            }

            MButton {
                text: NotifManager.dndEnabled ? "󰂛" : "󰂚"
                font: ThemeManager.selectedTheme.typography.iconFont
                implicitWidth: 35
                implicitHeight: 30
                onClicked: NotifManager.toggleDnd()

                ToolTip.visible: hovered
                ToolTip.text: NotifManager.dndEnabled ? "Disable DND" : "Enable DND"
                ToolTip.delay: 500
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: ThemeManager.selectedTheme.colors.dividerColor || "#22ffffff"
            opacity: 0.3
        }

        // Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Empty State
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                visible: notifModel.count === 0
                opacity: visible ? 0.6 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                Text {
                    text: "󰂚"
                    font: ThemeManager.selectedTheme.typography.iconFont
                    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: qsTr("No Notifications")
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Notification List
            ScrollView {
                anchors.fill: parent
                visible: notifModel.count > 0
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    id: notifView
                    width: parent.width
                    model: notifModel

                    spacing: 12
                    topMargin: 5
                    bottomMargin: 10
                    cacheBuffer: 2000

                    // ------------------------------------------------------------
                    // Animation Properties
                    // ------------------------------------------------------------
                    property real pullStartDistance: 5
                    property real recoilRightDistance: 15
                    property real shockOffset: 0
                    property real pullOffset: 0
                    property bool userIsDragging: false

                    // ------------------------------------------------------------
                    // Helper Functions
                    // ------------------------------------------------------------
                    function triggerSway() {
                        swayAnim.restart();
                    }

                    function animateAndClearAll() {
                        if (notifModel.count > 0) {
                            clearAllSequence.start();
                        }
                    }

                    // ------------------------------------------------------------
                    // Animations & Behaviors
                    // ------------------------------------------------------------

                    // Smooth pull behavior (disabled while dragging for instant response)
                    Behavior on pullOffset {
                        enabled: !notifView.userIsDragging
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    // "Clear All" Sequence
                    SequentialAnimation {
                        id: clearAllSequence

                        // 1. Move everything right and fade out
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

                        // 2. Logic: Clear data
                        ScriptAction {
                            script: NotifManager.clearAllNotifs()
                        }

                        // 3. Reset properties (instantly, while invisible)
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

                    // Recoil/Sway Animation (Shock effect)
                    SequentialAnimation {
                        id: swayAnim

                        // Kick right
                        NumberAnimation {
                            target: notifView
                            property: "shockOffset"
                            to: notifView.recoilRightDistance
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                        // Elastic return
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

                    // Standard Transitions
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
                                // NumberAnimation {
                                //     property: "scale"
                                //     to: 0.9
                                //     duration: 200
                                // }
                            }
                            NumberAnimation {
                                property: "height"
                                to: 0
                                duration: 450
                                easing.type: Easing.InOutQuart
                            }
                        }
                    }

                    // ------------------------------------------------------------
                    // Delegate
                    // ------------------------------------------------------------
                    delegate: Item {
                        id: wrapper
                        width: notifView.width
                        height: actualItem.implicitHeight

                        // Apply global list movement (Tension + Shock)
                        transform: [
                            Translate {
                                x: notifView.pullOffset + notifView.shockOffset
                            }
                        ]

                        // Swipe Container (Handles dragging logic)
                        Item {
                            id: swipeContainer
                            width: parent.width
                            height: actualItem.implicitHeight

                            // Reset position smoothly if not dragging
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
                                        // Calculate list tension based on drag distance
                                        var tension = Math.max(0, swipeContainer.x / 12);
                                        notifView.pullOffset = Math.min(tension, 30);
                                    }
                                }

                                onReleased: {
                                    notifView.userIsDragging = false;

                                    if (swipeContainer.x > 120) {
                                        // Action: Dismiss
                                        notifView.pullOffset = 0; // Snap list back (creates shock)
                                        swipeContainer.x = 600;   // Throw item away

                                        if (model.smartNotif)
                                            model.smartNotif.notification.dismiss();
                                    } else {
                                        // Action: Cancel
                                        swipeContainer.x = 0;
                                        notifView.pullOffset = 0;
                                    }
                                }
                            }

                            // Actual Notification Content
                            NotificationItem {
                                id: actualItem
                                width: swipeContainer.width

                                notification: model.smartNotif
                                theme: ThemeManager.selectedTheme

                                // Fade out while dragging
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

                                // Handle "X" button press (Tension effect)
                                onDismissPressedChanged: {
                                    if (!dragArea.drag.active) {
                                        notifView.pullOffset = dismissPressed ? notifView.pullStartDistance : 0;
                                    }
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
}

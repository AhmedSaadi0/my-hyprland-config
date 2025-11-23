import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/services"
import "root:/themes"
import "root:/components"
import "root:/components/notifications"

Item {
    id: root

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

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
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
                onClicked: NotifManager.clearAllNotifs()
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

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: ThemeManager.selectedTheme.colors.dividerColor || "#22ffffff"
            opacity: 0.3
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

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
                    topMargin: 35

                    cacheBuffer: 2000
                    property real swayOffset: 0

                    function triggerSway() {
                        swayAnim.restart();
                    }

                    SequentialAnimation {
                        id: swayAnim

                        NumberAnimation {
                            target: notifView
                            property: "swayOffset"
                            to: 15
                            duration: 150
                            easing.type: Easing.OutQuad
                        }

                        NumberAnimation {
                            target: notifView
                            property: "swayOffset"
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
                                NumberAnimation {
                                    property: "scale"
                                    to: 0.9
                                    duration: 200
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

                        transform: Translate {
                            x: notifView.swayOffset
                        }

                        NotificationItem {
                            id: actualItem
                            width: wrapper.width

                            opacity: 0
                            scale: 0.85
                            transform: Translate {
                                y: -30
                            }

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
                                    target: actualItem.transform
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
                                onTriggered: actualItem.opacity = 1
                            }

                            notification: model.smartNotif
                            theme: ThemeManager.selectedTheme

                            onDismissClicked: {
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

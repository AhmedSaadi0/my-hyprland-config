// NotificationList.qml
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
                    notifModel.remove(i);
                    break;
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            MButton {
                text: qsTr("Clear All")
                implicitHeight: 25
                implicitWidth: 75
                enabled: notifModel.count > 0
                topRightRadius: 0
                bottomRightRadius: 0
                onClicked: NotifManager.clearAllNotifs()
            }
            MButton {
                text: NotifManager.dndEnabled ? "󰂛" : "󰂚"
                font: ThemeManager.selectedTheme.typography.iconFont
                implicitWidth: 35
                implicitHeight: 25
                topLeftRadius: 0
                bottomLeftRadius: 0
                onClicked: NotifManager.toggleDnd()
            }
        }

        ScrollView {
            id: notifScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: notifView
                width: notifScroll.width
                model: notifModel
                spacing: ThemeManager.selectedTheme.dimensions.spacingLarge
                topMargin: ThemeManager.selectedTheme.dimensions.spacingLarge
                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1.0
                            duration: 400
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.8
                            to: 1.0
                            duration: 400
                            easing.type: Easing.OutBack
                        }
                    }
                }
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 300
                        }
                        NumberAnimation {
                            property: "scale"
                            to: 0.8
                            duration: 300
                            easing.type: Easing.InCubic
                        }
                    }
                }

                delegate: NotificationItem {
                    width: notifView.width
                    notification: model.smartNotif

                    onDismissClicked: {
                        if (model.smartNotif) {
                            model.smartNotif.notification.dismiss();
                        }
                    }
                    onActionInvoked: index => {
                        if (model.smartNotif) {
                            model.smartNotif.invokeAction(index);
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../utils"
import "../../themes"
import "../../components"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    //==================================================
    //  Data Model and Connections
    //==================================================
    ListModel {
        id: notifModel
    }

    Connections {
        target: NotifManager

        // When the manager says a new notification arrived
        function onNotificationReceived(smartNotifObject) {
            notifModel.insert(0, {
                "smartNotif": smartNotifObject
            });
        }

        // When the manager confirms a notification was closed
        function onNotificationClosed(smartNotifObject) {
            // Find the corresponding item in our model and remove it
            for (let i = 0; i < notifModel.count; ++i) {
                if (notifModel.get(i).smartNotif === smartNotifObject) {
                    notifModel.remove(i);
                    break;
                }
            }
        }
    }

    //==================================================
    //  Visual Layout
    //==================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Row {

            Layout.alignment: Qt.AlignRight
            // Layout.bottomMargin: ThemeManager.selectedTheme.spacingLarge

            MButton {
                id: clearAllButton
                implicitHeight: 25

                text: "Clear All"
                enabled: notifModel.count > 0

                topRightRadius: 0
                bottomRightRadius: 0

                onClicked: {
                    NotifManager.clearAllNotifs();
                }
            }

            MButton {
                id: dnd
                text: NotifManager.dndEnabled ? "󰂛" : "󰂚"
                font: ThemeManager.selectedTheme.typography.iconFont

                implicitWidth: 35
                implicitHeight: 25

                // enabled: notifModel.count > 0

                topLeftRadius: 0
                bottomLeftRadius: 0

                onClicked: {
                    NotifManager.toggleDnd();
                }
            }
        }

        ScrollView {
            id: notifScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.active: true

            ListView {
                id: notifView
                width: notifScroll.width
                implicitHeight: contentHeight
                interactive: false
                clip: true

                // 3. The model is our clean ListModel.
                model: notifModel
                spacing: ThemeManager.selectedTheme.typography.spacingLarge
                topMargin: ThemeManager.selectedTheme.dimensions.spacingLarge

                // 4. All transitions are defined here and will work perfectly.
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

                //==================================================
                //  Delegate for Each Notification
                //==================================================
                delegate: Rectangle {
                    id: delegateRoot
                    width: notifView.width
                    color: ThemeManager.selectedTheme.colors.topbarBgColorV1
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    implicitHeight: contentLayout.implicitHeight + 32

                    property var notif: model.smartNotif

                    ColumnLayout {
                        id: contentLayout
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: ThemeManager.selectedTheme.typography.spacingMedium

                        // -- Row 1: App Name, Time, Close Button
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Item {
                                width: 16
                                height: 16
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    text: "✕"
                                    font.pixelSize: 14
                                    anchors.centerIn: parent
                                    color: ThemeManager.selectedTheme.colors.primary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // ** The Logic: Just call dismiss on the original notification object **
                                        // The smart Notif object in the backend will handle the rest.
                                        if (notif && notif.notification) {
                                            notif.notification.dismiss();
                                        }
                                        enabled = false;
                                    }
                                }
                            }
                            Text {
                                text: notif ? notif.appName : ""
                                font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: notif ? notif.timeStr : ""
                                font.pixelSize: ThemeManager.selectedTheme.typography.small
                                color: ThemeManager.selectedTheme.colors.subtleText
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: ThemeManager.selectedTheme.typography.spacingMedium
                            Item {
                                width: 24
                                height: 24
                                Layout.alignment: Qt.AlignVCenter
                                // visible: notif && notif.image
                                Image {
                                    anchors.fill: parent
                                    source: notif ? notif.image : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                            }
                            Text {
                                text: notif ? notif.summary : ""
                                font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                                font.bold: true
                                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            text: notif ? notif.body : ""
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            font.pixelSize: ThemeManager.selectedTheme.typography.medium
                            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                            Layout.fillWidth: true
                        }

                        // RowLayout {
                        //     visible: notif.actions && notif.actions.length > 0
                        //     spacing: ThemeManager.selectedTheme.typography.spacingMedium
                        //     Repeater {
                        //         model: notif.actions
                        //         Button {
                        //             text: modelData.label
                        //             font.pixelSize: ThemeManager.selectedTheme.typography.small
                        //             onClicked: modelData.trigger()
                        //         }
                        //     }
                        // }
                    }
                }
            }
        }
    }
}

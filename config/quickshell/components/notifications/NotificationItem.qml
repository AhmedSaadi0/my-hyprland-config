// components/notifications/NotificationItem.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "root:/themes"
import "root:/components"

Rectangle {
    id: root

    property var notification
    signal dismissClicked
    signal actionInvoked(int index)

    implicitHeight: contentLayout.implicitHeight + (ThemeManager.selectedTheme.dimensions.spacingLarge * 2)
    color: ThemeManager.selectedTheme.colors.topbarBgColorV1
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    ColumnLayout {
        id: contentLayout

        anchors.fill: parent
        anchors.margins: ThemeManager.selectedTheme.dimensions.spacingLarge
        spacing: ThemeManager.selectedTheme.typography.spacingMedium

        // -- 1. Header Row: Close Button, App Name, Time --
        RowLayout {
            Layout.fillWidth: true
            spacing: ThemeManager.selectedTheme.typography.spacingSmall

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
                        root.dismissClicked(); // إرسال إشارة بدلاً من تنفيذ المنطق مباشرة
                        enabled = false; // تعطيل الزر لمنع النقرات المتعددة
                    }
                }
            }

            Text {
                text: notification ? notification.appName : ""
                font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: notification ? notification.timeStr : ""
                font.pixelSize: ThemeManager.selectedTheme.typography.small
                color: ThemeManager.selectedTheme.colors.subtleText
                Layout.alignment: Qt.AlignTop
            }
        }

        // -- 2. Summary Row: Icon and Title --
        RowLayout {
            Layout.fillWidth: true
            spacing: ThemeManager.selectedTheme.typography.spacingMedium
            visible: notification && (notification.image || notification.summary)

            Image {
                source: notification ? notification.image : ""
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: source !== ""
            }

            Text {
                text: notification ? notification.summary : ""
                font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                font.bold: true
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // -- 3. Body Text --
        Text {
            text: notification ? notification.body : ""
            visible: text !== ""
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.pixelSize: ThemeManager.selectedTheme.typography.medium
            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            Layout.fillWidth: true
        }

        // -- 4. Action Buttons --
        RowLayout {
            Layout.fillWidth: true
            visible: notification && notification.displayActions && notification.displayActions.length > 0
            spacing: ThemeManager.selectedTheme.typography.spacingMedium

            Repeater {
                model: notification ? notification.displayActions : []

                delegate: MButton {
                    text: modelData.text !== "" ? modelData.text : "Do Action"
                    Layout.fillWidth: true
                    textElide: Text.ElideRight

                    onClicked: root.actionInvoked(index)
                }
            }
        }
    }
}

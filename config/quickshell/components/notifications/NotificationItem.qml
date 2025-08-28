// components/notifications/NotificationItem.qml

import QtQuick
import QtQuick.Layouts
// import Quickshell.Services.Notifications

import "root:/components"
import "root:/config"

Rectangle {
    id: root

    // --- الواجهة العامة للمكون (Public API) ---
    property var notification
    property var theme // <<< خاصية لاستقبال كائن السمة
    property string defaultIcon: App.assets.icons.notification

    signal dismissClicked
    signal actionInvoked(int index)

    // --- استخدام السمة المحقونة (injected theme) مع قيم افتراضية ---
    implicitHeight: contentLayout.implicitHeight + (root.theme ? (root.theme.dimensions.spacingLarge * 2) : 16)
    color: root.theme ? root.theme.colors.topbarBgColorV1 : "#EEEEEE"
    radius: root.theme ? root.theme.dimensions.elementRadius : 8

    ColumnLayout {
        id: contentLayout

        anchors.fill: parent
        anchors.margins: root.theme ? root.theme.dimensions.spacingLarge : 8
        spacing: root.theme ? root.theme.typography.spacingMedium : 6

        // -- 1. Header Row: Close Button, App Name, Time --
        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme ? root.theme.typography.spacingSmall : 4

            Item {
                width: 16
                height: 16
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "✕"
                    font.pixelSize: 14
                    anchors.centerIn: parent
                    color: root.theme ? root.theme.colors.primary : "blue"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.dismissClicked();
                        enabled = false;
                    }
                }
            }

            Text {
                text: notification ? notification.appName : ""
                font.pixelSize: root.theme ? root.theme.typography.heading4Size : 16
                color: root.theme ? root.theme.colors.topbarFgColorV1 : "black"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: notification ? notification.timeStr : ""
                font.pixelSize: root.theme ? root.theme.typography.small : 12
                color: root.theme ? root.theme.colors.subtleText : "gray"
                Layout.alignment: Qt.AlignTop
            }
        }

        // -- 2. Summary Row: Icon and Title --
        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme ? root.theme.typography.spacingMedium : 6
            visible: notification && (notification.image || notification.summary)

            Image {
                source: notification ? (notification.image || notification.appIcon || defaultIcon) : defaultIcon
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: source !== ""
            }

            Text {
                text: notification ? notification.summary : ""
                font.pixelSize: root.theme ? root.theme.typography.heading4Size : 16
                font.bold: true
                color: root.theme ? root.theme.colors.topbarFgColorV1 : "black"
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
            font.pixelSize: root.theme ? root.theme.typography.medium : 14
            color: root.theme ? root.theme.colors.leftMenuFgColorV1 : "darkgray"
            Layout.fillWidth: true
        }

        // -- 4. Action Buttons --
        RowLayout {
            Layout.fillWidth: true
            visible: notification && notification.displayActions && notification.displayActions.length > 0
            spacing: root.theme ? root.theme.typography.spacingMedium : 6

            Repeater {
                model: notification ? notification.displayActions : []

                delegate: MButton {
                    text: modelData.text !== "" ? modelData.text : "Do Action"
                    Layout.fillWidth: true
                    textElide: Text.ElideRight

                    // تمرير السمة إلى المكون الفرعي
                    // theme: root.theme

                    onClicked: root.actionInvoked(index)
                }
            }
        }
    }
}

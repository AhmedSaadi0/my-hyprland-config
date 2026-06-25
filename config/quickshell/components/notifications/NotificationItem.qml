// components/notifications/NotificationItem.qml

import QtQuick
import QtQuick.Layouts
import "root:/components"
import "root:/config"
import "root:/config/ConstValues.js" as Consts
import "root:/themes"

Rectangle {
    id: root

    property var notification
    property var theme: ThemeManager.selectedTheme
    property string defaultIcon: App.assets.icons.notification
    property real progress: 0.0
    property bool visibleProgress: false

    property int innerRadiusDiv: 4

    property bool dismissPressed: closeBtnMouseArea.pressed

    signal dismissClicked
    signal actionInvoked(int index)

    implicitHeight: contentLayout.implicitHeight + (root.theme.dimensions.spacingLarge * 2)
    color: root.theme.colors.surfaceContainerHigh
    radius: root.theme.dimensions.elementRadius

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: root.theme.dimensions.spacingLarge
        spacing: root.theme.dimensions.spacingMedium

        // -- 1. Header Row --
        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme.dimensions.spacingSmall

            Item {
                width: 20
                height: 20
                Layout.alignment: Qt.AlignVCenter

                CircularProgress {
                    id: dismissProgress
                    anchors.centerIn: parent
                    width: parent.width + 2
                    height: parent.height + 2
                    thickness: 2
                    margin: 1
                    value: root.progress
                    foregroundColor: root.theme.colors.primary
                    backgroundColor: root.theme.colors.primary.alpha(0.3)
                    visible: root.visibleProgress
                    enableAnimation: false
                }

                Text {
                    id: closeBtn
                    text: ""
                    font.family: theme.typography.iconFont
                    font.pixelSize: 14
                    anchors.centerIn: parent
                    color: root.theme.colors.primary
                }

                MouseArea {
                    id: closeBtnMouseArea
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
                font.pixelSize: root.theme.typography.heading4Size
                color: root.theme.colors.onSurface
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: notification ? notification.timeStr : ""
                font.pixelSize: root.theme.typography.small
                color: root.theme.colors.onSurfaceVariant
                Layout.alignment: Qt.AlignTop
            }
        }

        // -- 2. Summary Row --
        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme.dimensions.spacingMedium
            visible: notification && (notification.image || notification.summary)

            Image {
                id: notifImage

                property string rawIcon: notification ? (notification.image || notification.appIcon || "") : ""

                source: {
                    if (rawIcon === "")
                        return defaultIcon;

                    // إذا كان يحتوي على "/" أو يبدأ بـ "file://" فهو مسار ملف مباشر
                    if (rawIcon.indexOf("/") !== -1 || rawIcon.indexOf("file://") === 0) {
                        return rawIcon;
                    }

                    // التعديل: استخدام image://icon بدلاً من image://theme المتوافقة مع Quickshell
                    return "image://icon/" + rawIcon;
                }

                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: status === Image.Ready // إخفاء الصورة حتى تجهز لتجنب الوميض

                // نظام حماية (Fallback) مع حماية ضد التكرار اللانهائي
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.warn("Notification Image Failed:", rawIcon, "- Reverting to default.");
                        // التحقق من أن المصدر الحالي ليس هو الافتراضي بالفعل لمنع تعليق البرنامج
                        if (source !== defaultIcon) {
                            source = defaultIcon;
                        }
                    }
                }
            }

            Text {
                text: notification ? notification.summary : ""
                font.pixelSize: root.theme.typography.heading4Size
                font.bold: true
                color: root.theme.colors.onSurface
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
            font.pixelSize: root.theme.typography.medium
            color: root.theme.colors.onSurface
            Layout.fillWidth: true
        }

        // -- 4. Action Buttons --
        RowLayout {
            Layout.fillWidth: true
            visible: notification && notification.displayActions && notification.displayActions.length > 0
            spacing: 3

            Repeater {
                id: actionRepeater
                model: notification ? notification.displayActions : []

                delegate: MButton {
                    property int groupRadius: root.theme.dimensions.elementRadius / Consts.M3_BUTTON_RADIUS_DIVISOR

                    text: modelData.text !== "" ? modelData.text : "Do Action"
                    Layout.fillWidth: true
                    textElide: Text.ElideRight
                    onClicked: root.actionInvoked(index)

                    topLeftRadius: index === 0 ? groupRadius : groupRadius / root.innerRadiusDiv
                    bottomLeftRadius: index === 0 ? groupRadius : groupRadius / root.innerRadiusDiv
                    topRightRadius: index === actionRepeater.count - 1 ? groupRadius : groupRadius / root.innerRadiusDiv
                    bottomRightRadius: index === actionRepeater.count - 1 ? groupRadius : groupRadius / root.innerRadiusDiv
                }
            }
        }
    }
}

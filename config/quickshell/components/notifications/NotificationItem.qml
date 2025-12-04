// components/notifications/NotificationItem.qml

import QtQuick
import QtQuick.Layouts
import "root:/components"
import "root:/config"

Rectangle {
    id: root

    property var notification
    property var theme
    property string defaultIcon: App.assets.icons.notification
    property real progress: 0.0
    property bool visibleProgress: false

    property bool dismissPressed: closeBtnMouseArea.pressed

    signal dismissClicked
    signal actionInvoked(int index)

    implicitHeight: contentLayout.implicitHeight + (root.theme ? (root.theme.dimensions.spacingLarge * 2) : 16)
    color: root.theme ? root.theme.colors.topbarBgColorV1 : "#EEEEEE"
    radius: root.theme ? root.theme.dimensions.elementRadius : 8

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: root.theme ? root.theme.dimensions.spacingLarge : 8
        spacing: root.theme ? root.theme.typography.spacingMedium : 6

        // -- 1. Header Row --
        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme ? root.theme.typography.spacingSmall : 4

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
                    foregroundColor: root.theme ? root.theme.colors.primary : "blue"
                    backgroundColor: root.theme ? root.theme.colors.primary.alpha(0.3) : "#330000FF"
                    visible: root.visibleProgress
                    enableAnimation: false
                }

                Text {
                    id: closeBtn
                    text: ""
                    font.family: theme.typography.iconFont
                    font.pixelSize: 14
                    anchors.centerIn: parent
                    color: root.theme ? root.theme.colors.primary : "blue"
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

            // ... (باقي العناصر كما هي بدون تغيير) ...
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

        // -- 2. Summary Row --
        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme ? root.theme.typography.spacingMedium : 6
            visible: notification && (notification.image || notification.summary)

            Image {
                id: notifImage

                property string rawIcon: notification ? (notification.image || notification.appIcon || "") : ""

                source: {
                    if (rawIcon === "")
                        return defaultIcon;

                    // إذا كان يحتوي على "/" أو يبدأ بـ "file://" فهو مسار ملف
                    if (rawIcon.indexOf("/") !== -1 || rawIcon.indexOf("file://") === 0) {
                        return rawIcon;
                    }

                    // عدا ذلك، هو اسم أيقونة نظام، نستخدم بادئة الثيم
                    return "image://theme/" + rawIcon;
                }

                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: status === Image.Ready // إخفاء الصورة حتى تجهز لتجنب الوميض

                // 2. نظام حماية (Fallback) في حال فشل التحميل
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.warn("Notification Image Failed:", rawIcon, "- Reverting to default.");
                        source = defaultIcon;
                    }
                }
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
                    onClicked: root.actionInvoked(index)
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts

import "../../themes"

// هذا المكون يعرض إشعاراً واحداً فقط.
// إنه لا يتصل بأي مدير منطق (logic manager) مباشرة، مما يجعله قابلاً لإعادة الاستخدام.
Rectangle {
    id: root

    // --- الخصائص العامة للمكون
    property var notification // كائن الإشعار الكامل من النموذج
    signal dismissClicked // إشارة لإعلام المكون الأب بطلب الإغلاق

    // --- المظهر
    implicitHeight: contentLayout.implicitHeight + 32 // الهوامش العمودية 16*2
    color: ThemeManager.selectedTheme.colors.topbarBgColorV1
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    // --- التخطيط الداخلي
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: ThemeManager.selectedTheme.typography.spacingMedium

        // --- السطر الأول: اسم التطبيق، الوقت، زر الإغلاق
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // زر الإغلاق المخصص
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

            // اسم التطبيق
            Text {
                text: notification ? notification.appName : ""
                font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // الوقت
            Text {
                text: notification ? notification.timeStr : ""
                font.pixelSize: ThemeManager.selectedTheme.typography.small
                color: ThemeManager.selectedTheme.colors.subtleText
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // --- السطر الثاني: أيقونة الإشعار والملخص
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
                    source: notification ? notification.image : ""
                    // source: notif ? notif.image : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            Text {
                text: notification ? notification.summary : ""
                font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                font.bold: true
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        // --- نص الإشعار
        Text {
            text: notification ? notification.body : ""
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.pixelSize: ThemeManager.selectedTheme.typography.medium
            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            Layout.fillWidth: true
            visible: text !== "" // إخفاء النص إذا كان فارغاً
        }

        // --- مساحة مخصصة للأزرار التفاعلية (مستقبلاً)
        // RowLayout {
        //     visible: notification.actions && notification.actions.length > 0
        //     spacing: ThemeManager.selectedTheme.typography.spacingMedium
        //     Repeater {
        //         model: notification.actions
        //         Button {
        //             text: modelData.label
        //         }
        //     }
        // }
    }
}

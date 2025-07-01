import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// --- استيراد المكونات المخصصة
import "../../../services"
import "../../../themes"
import "../../../components"

Item {
    id: root

    // --- خصائص التخطيط
    Layout.fillWidth: true
    Layout.fillHeight: true

    //==================================================
    //  1. البيانات والاتصالات (Data & Logic)
    //==================================================

    ListModel {
        id: notifModel
    }

    Connections {
        target: NotifManager

        // عند وصول إشعار جديد من المدير
        function onNotificationReceived(smartNotifObject) {
            notifModel.insert(0, {
                "smartNotif": smartNotifObject
            });
        }

        // عند تأكيد إغلاق إشعار
        function onNotificationClosed(smartNotifObject) {
            // البحث عن العنصر المطابق في النموذج وحذفه
            // ملاحظة: هذا البحث قد يكون بطيئاً إذا كانت القائمة طويلة جداً
            for (let i = 0; i < notifModel.count; ++i) {
                if (notifModel.get(i).smartNotif === smartNotifObject) {
                    notifModel.remove(i);
                    break;
                }
            }
        }
    }

    //==================================================
    //  2. الواجهة الرسومية (UI Layout)
    //==================================================

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- الأزرار العلوية (Header)
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight

            MButton {
                text: qsTr("Clear All") // استخدام qsTr للترجمة مستقبلاً
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

        // --- قائمة الإشعارات
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
                interactive: false // التمرير يتم عبر ScrollView
                clip: true

                model: notifModel
                spacing: ThemeManager.selectedTheme.dimensions.spacingLarge
                topMargin: ThemeManager.selectedTheme.dimensions.spacingLarge

                // --- الرسوم المتحركة (Transitions)
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

                // --- مندوب عرض كل إشعار (Delegate)
                delegate: NotificationItem {
                    width: notifView.width

                    // ربط بيانات النموذج بخصائص المكون
                    notification: model.smartNotif

                    // عند طلب إغلاق الإشعار من المكون، نقوم بتنفيذ المنطق هنا
                    onDismissClicked: {
                        if (model.smartNotif && model.smartNotif.notification) {
                            model.smartNotif.notification.dismiss();
                        }
                    }
                }
            }
        }
    }
}

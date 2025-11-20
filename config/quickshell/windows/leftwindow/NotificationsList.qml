import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/services"
import "root:/themes"
import "root:/components"
import "root:/components/notifications"

Item {
    id: root

    // --- البيانات والمنطق ---
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

    // --- التصميم ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10 // هوامش لترتيب المحتوى عن الحواف
        spacing: 10

        // 1. شريط العنوان والأدوات (Header)
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            // العنوان + العداد
            Text {
                text: qsTr("Notifications")
                font.bold: true
                font.pixelSize: 16
                color: ThemeManager.selectedTheme.colors.textPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            // شارة العداد (تظهر فقط عند وجود إشعارات)
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
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            // فراغ لدفع الأزرار لجهة اليمين
            Item {
                Layout.fillWidth: true
            }

            // الأزرار (تم فصلها لتكون أجمل بصرياً بدلاً من التصاقها)

            // زر مسح الكل
            MButton {
                text: qsTr("Clear All")
                implicitHeight: 30
                implicitWidth: 80
                visible: notifModel.count > 0 // يختفي إذا لم تكن هناك إشعارات
                onClicked: NotifManager.clearAllNotifs()
            }

            // زر عدم الإزعاج (DND)
            MButton {
                text: NotifManager.dndEnabled ? "󰂛" : "󰂚"
                font: ThemeManager.selectedTheme.typography.iconFont
                implicitWidth: 35
                implicitHeight: 30
                // يمكنك استخدام لون مختلف في الخلفية إذا كان MButton يدعم خاصية color
                // color: NotifManager.dndEnabled ? ThemeManager.selectedTheme.colors.primary : ...

                onClicked: NotifManager.toggleDnd()

                // إضافة ToolTip إذا أردت
                ToolTip.visible: hovered
                ToolTip.text: NotifManager.dndEnabled ? "Disable DND" : "Enable DND"
                ToolTip.delay: 500
            }
        }

        // فاصل
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: ThemeManager.selectedTheme.colors.dividerColor || "#22ffffff"
            opacity: 0.3
        }

        // 2. منطقة المحتوى (تجمع بين القائمة وحالة الفراغ)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // أ: حالة الفراغ (تظهر عند عدم وجود إشعارات)
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
                    text: "󰂚" // أيقونة الجرس
                    font: ThemeManager.selectedTheme.typography.iconFont
                    // font.pixelSize: 48
                    color: ThemeManager.selectedTheme.colors.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: qsTr("No Notifications")
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // ب: القائمة الفعلية
            ScrollView {
                anchors.fill: parent
                visible: notifModel.count > 0

                // إخفاء شريط التمرير الأفقي
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    id: notifView
                    width: parent.width
                    model: notifModel

                    spacing: 12
                    topMargin: 35
                    // bottomMargin: 24

                    // الحفاظ على العناصر في الذاكرة لمنع التقطيع
                    cacheBuffer: 2000

                    // --- 1. حركة إعادة الترتيب (نحتفظ بها هنا لأنها وظيفة القائمة) ---
                    displaced: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: 600
                            easing.type: Easing.OutQuart
                        }
                    }

                    // --- 2. حركة الحذف (نحتفظ بها هنا لتنسيق إغلاق الفراغ) ---
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

                    // --- 3. الديليجيت (Delegate) ---
                    delegate: Item {
                        id: wrapper
                        width: notifView.width
                        // نربط ارتفاع الغلاف بارتفاع الإشعار الفعلي لضمان عمل القائمة بشكل صحيح
                        height: actualItem.implicitHeight

                        // هذا هو العنصر الفعلي
                        NotificationItem {
                            id: actualItem
                            width: wrapper.width

                            // --- الحالة الأولية (مخفي) ---
                            opacity: 0
                            scale: 0.85
                            transform: Translate {
                                y: -30
                            } // نستخدم Translate بدلاً من y لتجنب مشاكل التخطيط

                            // --- أنيميشن الدخول المستقل (Android 16 Style) ---
                            ParallelAnimation {
                                id: entryAnim
                                running: true // يعمل تلقائياً بمجرد إنشاء العنصر

                                // 1. الشفافية (مضمونة الوصول لـ 1)
                                NumberAnimation {
                                    target: actualItem
                                    property: "opacity"
                                    to: 1
                                    duration: 250 // سريعة جداً
                                    easing.type: Easing.Linear
                                }

                                // 2. التكبير (فيزياء)
                                NumberAnimation {
                                    target: actualItem
                                    property: "scale"
                                    to: 1
                                    duration: 550
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.0
                                }

                                // 3. الهبوط (فيزياء)
                                NumberAnimation {
                                    target: actualItem.transform
                                    property: "y"
                                    to: 0
                                    duration: 550
                                    easing.type: Easing.OutQuint
                                }
                            }

                            // --- صمام أمان (Safety Valve) ---
                            // في حال حدوث أي خطأ في الأنيميشن بسبب الضغط الشديد،
                            // هذا المؤقت سيجبر العنصر على الظهور بعد جزء من الثانية
                            Timer {
                                interval: 300
                                running: true
                                repeat: false
                                onTriggered: actualItem.opacity = 1
                            }

                            // --- البيانات والوظائف ---
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

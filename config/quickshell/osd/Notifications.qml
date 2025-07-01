import QtQuick
import Quickshell

// import QtQuick.Controls
// import QtQuick.Layouts
import QtQuick.Effects

import "../components"
// import "../themes"
import "../services"

// هذه النافذة تظهر كإشعار منبثق "Toast" عند وصول إشعار جديد
PanelWindow {
    id: root

    // --- خصائص النافذة
    // العرض والارتفاع سيعتمدان على حجم المحتوى
    implicitWidth: panelContent.width + 20  // عرض المحتوى + هوامش
    implicitHeight: panelContent.height + 40 // ارتفاع المحتوى + هوامش للظهور والاختفاء
    color: "transparent"
    visible: false

    // --- خصائص تحديد الموضع على الشاشة
    exclusionMode: ExclusionMode.Ignore
    margins {
        bottom: 10
    }
    anchors {
        bottom: true
        left: true
    }

    // --- حالة النافذة والبيانات
    property bool showing: false
    property var currentNotification: null // <-- 2. خاصية لتخزين الإشعار الحالي

    // --- مؤقتات الإخفاء التلقائي
    Timer {
        id: hideContainerTimer
        interval: 5000 // زيادة الوقت قليلاً ليكون المستخدم قادراً على القراءة
        repeat: false
        onTriggered: root.showing = false
    }

    Timer {
        id: hideViewTimer
        interval: hideContainerTimer.interval + 300 // يختفي بعد انتهاء حركة الخروج
        repeat: false
        onTriggered: root.visible = false
    }

    // --- الاتصال بمدير الإشعارات
    Connections {
        target: NotifManager

        function onNotificationReceived(smartNotifObject) {
            // تحديث بيانات الإشعار
            root.currentNotification = smartNotifObject;

            // إظهار النافذة وإعادة تشغيل المؤقتات
            root.showing = true;
            root.visible = true;
            hideContainerTimer.restart();
            hideViewTimer.restart();
        }

        // عند إغلاق الإشعار من مكان آخر (مثل القائمة الرئيسية)
        function onNotificationClosed(smartNotifObject) {
            // إذا كان هو نفس الإشعار المعروض حالياً، قم بإخفائه
            if (root.currentNotification === smartNotifObject) {
                root.showing = false;
                // لا نحتاج لإيقاف المؤقتات، لأن `showing = false` ستؤدي إلى إخفائه
            }
        }
    }

    // --- حاوية المحتوى للتحكم في حركة الدخول والخروج
    Item {
        id: panelContainer
        anchors.fill: parent

        states: State {
            name: "visible"
            when: root.showing
            PropertyChanges {
                target: panelContent
                y: 20 // الموضع النهائي بعد الحركة
                opacity: 1
            }
        }

        transitions: Transition {
            NumberAnimation {
                properties: "y, opacity"
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // <-- 3. تم استبدال المحتوى بالمكون الجديد
        NotificationItem {
            id: panelContent
            width: 350 // تحديد عرض مناسب للإشعار المنبثق

            // تحديد الموضع الأولي للحركة
            y: root.height
            opacity: 0
            anchors.horizontalCenter: parent.horizontalCenter

            // <-- 4. ربط بيانات الإشعار
            notification: root.currentNotification

            // تطبيق تأثير الظل مباشرة على المكون
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 1.1
                shadowColor: "#55000000"
                shadowHorizontalOffset: 4
                shadowVerticalOffset: 4
                shadowOpacity: 0.5
            }

            // <-- 5. التعامل مع حدث النقر على زر الإغلاق
            onDismissClicked: {
                // إخفاء النافذة فوراً
                root.showing = false;

                // إبلاغ المدير بأن الإشعار قد تم إغلاقه
                if (notification && notification.notification) {
                    notification.notification.dismiss();
                }
            }
        }
    }
}

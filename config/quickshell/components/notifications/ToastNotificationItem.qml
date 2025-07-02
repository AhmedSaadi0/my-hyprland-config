// ToastNotificationPopup.qml
import QtQuick
// import QtQuick.Layouts
import QtQuick.Effects

// import "../../components"

Item {
    id: root

    width: notificationItem.width
    height: notificationItem.height

    // --- الخصائص والإشارات
    property var notification
    signal requestRemove // إشارة لإعلام الحاوية بأن هذا العنصر يجب أن يُحذف

    // --- الحالة والرسوم المتحركة
    property bool showing: false
    opacity: 0
    scale: 0.9

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    states: State {
        name: "visible"
        when: showing
        PropertyChanges {
            target: root
            opacity: 1
            scale: 1.0
        }
    }

    // --- المؤقتات والمنطق
    Timer {
        id: hideTimer
        interval: 3000 // مدة بقاء الإشعار
        repeat: false
        onTriggered: {
            showing = false; // بدء حركة الاختفاء
            // بعد انتهاء الحركة، اطلب الحذف
            removeTimer.start();
        }
    }

    Timer {
        id: removeTimer
        interval: 300 // نفس مدة حركة الاختفاء
        repeat: false
        onTriggered: root.requestRemove()
    }

    // عند إنشاء المكون، أظهره وشغّل المؤقت
    Component.onCompleted: {
        showing = true;
        hideTimer.start();
    }

    // --- المحتوى المرئي
    NotificationItem {
        id: notificationItem
        width: 350
        notification: root.notification

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 1.1
            shadowColor: "#55000000"
            shadowHorizontalOffset: 4
            shadowVerticalOffset: 4
            shadowOpacity: 0.5
        }

        onDismissClicked: {
            if (root.notification && root.notification.notification) {
                root.notification.notification.dismiss();
            }
            // إيقاف المؤقت الرئيسي وبدء عملية الإزالة فوراً
            hideTimer.stop();
            showing = false;
            removeTimer.start();
        }
    }
}

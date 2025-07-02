// ToastNotificationHandler.qml
import QtQuick
import Quickshell
// import QtQuick.Controls
import QtQuick.Layouts

// import "../themes"
import "../services"
import "../components/notifications"

PanelWindow {
    id: root

    // الحجم سيعتمد على المحتوى الداخلي
    implicitWidth: popupContainer.implicitWidth + 20
    implicitHeight: popupContainer.implicitHeight + 20
    color: "transparent"
    visible: popupModel.count > 0 // النافذة تكون مرئية فقط إذا كان هناك إشعارات

    exclusionMode: ExclusionMode.Ignore
    margins {
        bottom: 30
        left: 30
    }

    anchors {
        bottom: true
        left: true
    }

    // نموذج بيانات لتخزين الإشعارات التي ستعرض
    ListModel {
        id: popupModel
    }

    // الاتصال بمدير الإشعارات
    Connections {
        target: NotifManager

        function onNotificationReceived(smartNotifObject) {
            // إضافة الإشعار الجديد إلى بداية القائمة
            if (!NotifManager.dndEnabled) {
                popupModel.insert(0, {
                    "notificationData": smartNotifObject
                });
            }
        }
    }

    // حاوية لرص الإشعارات فوق بعضها
    ColumnLayout {
        id: popupContainer
        spacing: 8

        // Repeater يقوم بإنشاء نسخة من المكون لكل عنصر في النموذج
        Repeater {
            model: popupModel

            // المكون الذي سيتم تكراره
            delegate: ToastNotificationItem {
                // تمرير بيانات الإشعار من النموذج إلى المكون
                notification: model.notificationData

                // عند طلب المكون للحذف (بعد انتهاء وقته أو النقر عليه)
                onRequestRemove: {
                    // ابحث عن العنصر في النموذج وقم بحذفه
                    // model.index يعطينا موقع العنصر الحالي
                    popupModel.remove(model.index);
                }
            }
        }
    }
}

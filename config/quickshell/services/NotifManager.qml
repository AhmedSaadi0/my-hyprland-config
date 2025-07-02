// NotifManager.qml (Final Self-Contained Version)
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dndEnabled: false

    // --- Signals for the UI ---
    // تطلق عند وصول إشعار جديد، وترسل كائن "Notif" الذكي
    signal notificationReceived(var smartNotifObject)

    // تطلق عندما يتم تأكيد حذف الإشعار، وترسل كائن "Notif" الذكي
    signal notificationClosed(var smartNotifObject)

    // --- Public Functions for the UI ---
    function clearAllNotifs() {
        // نمر على كل الإشعارات "الأصلية" ونطلب منها الحذف
        // هذا سيؤدي إلى إطلاق onDropped لكل واحد منها
        const allTracked = [...notifServer.trackedNotifications.values];
        for (const notif of allTracked) {
            notif.dismiss();
        }
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled;
    }

    Process {
        id: notificationSound
        command: ["paplay", ".config/quickshell/assets/audio/new-notification.mp3"]
    }

    // --- Server Logic ---
    NotificationServer {
        id: notifServer

        // ... (server properties)
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: originalNotif => {
            originalNotif.tracked = true;

            // 1. قم بإنشاء كائن Notif الذكي، ومرر له الإشعار الأصلي
            const newSmartNotif = notifComp.createObject(root, {
                notification: originalNotif
            });

            // 2. أطلق إشارة للواجهة بأن هناك إشعاراً جديداً جاهزاً
            root.notificationReceived(newSmartNotif);
            if (!root.dndEnabled) {
                notificationSound.running = true;
            }
        }
    }

    // --- The Smart "Notif" Object Definition ---
    component Notif: QtObject {
        id: notifComponent

        // The original notification object from the server
        required property Notification notification

        // Properties for direct access in the UI delegate
        readonly property string summary: notification ? notification.summary : ""
        readonly property string body: notification ? notification.body : ""
        readonly property string appIcon: notification ? notification.appIcon : ""
        readonly property string appName: notification ? notification.appName : ""
        readonly property string image: notification ? notification.image : ""
        readonly property int id: notification ? notification.id : 0

        // You can add computed properties here too
        readonly property date time: new Date()
        readonly property string timeStr: {
            return time.toLocaleTimeString([], {
                hour: '2-digit',
                minute: '2-digit'
            });
        }

        // This is the self-management logic!
        // This Connections block listens to the lifecycle of the original notification.
        readonly property Connections conn: Connections {
            // We listen to the Retainable object provided by Quickshell
            target: notifComponent.notification ? notifComponent.notification.Retainable : null

            // onDropped is emitted when the notification is dismissed or closed.
            function onDropped(): void {
                // When the original notification is dropped,
                // we emit our "closed" signal, sending this smart Notif object itself.
                root.notificationClosed(notifComponent);

                // We can now schedule this smart object for destruction
                notifComponent.destroy(500); // Destroy after 500ms to be safe
            }
        }
    }

    // A factory for creating Notif objects
    Component {
        id: notifComp
        Notif {}
    }
}

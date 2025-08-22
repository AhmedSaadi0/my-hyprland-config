// NotifManager.qml
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "root:/config"
import "root:/utils"

Singleton {
    id: root

    // ------------------------------------
    // --- Public API for UI Components ---
    // ------------------------------------

    property list<QtObject> activeNotifications: []
    readonly property var notificationCount: activeNotifications.length
    property bool dndEnabled: false

    signal notificationReceived(var smartNotifObject)
    signal notificationClosed(var smartNotifObject)

    function clearAllNotifs() {
        const allSmartNotifs = [...root.activeNotifications];
        for (const notif of allSmartNotifs) {
            notif.notification.dismiss();
        }
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled;
    }

    function notify({
        summary,
        body = "",
        icon = "",
        urgency = "normal",
        tone = App.assets.audio.notificationAlert
    }) {
        App.dispatchCommand("Notify", Helper.sendNotification({
            summary: summary,
            body: body,
            icon: icon,
            urgency: urgency
        }));
        playNotificationTone(tone);
    }

    function playNotificationTone(tone = App.assets.audio.notificationAlert) {
        if (!root.dndEnabled) {
            App.dispatchCommand("Notification tone", Helper.playSoundCommand(tone));
        }
    }

    NotificationServer {
        id: notifServer

        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: originalNotif => {
            originalNotif.tracked = true;

            const newSmartNotif = notifComp.createObject(root, {
                notification: originalNotif
            });

            root.activeNotifications.push(newSmartNotif);

            root.notificationReceived(newSmartNotif);

        // playNotificationTone();
        }
    }

    component Notif: QtObject {
        id: notifComponent

        required property Notification notification

        property string summary: ""
        property string body: ""
        property string appIcon: ""
        property string appName: ""
        property string image: ""
        property int notifId: 0
        property var displayActions: []

        onNotificationChanged: {
            if (!notification)
                return;

            summary = notification.summary;
            body = notification.body;
            appIcon = notification.appIcon.replace("file://", "");
            appName = notification.appName;
            image = notification.image.replace("file://", "");
            notifId = notification.id;

            var newActions = [];
            if (notification.actions) {
                for (var i = 0; i < notification.actions.length; i++) {
                    newActions.push({
                        "text": notification.actions[i].text
                    });
                }
            }
            displayActions = newActions;
        }

        function invokeAction(index) {
            if (notification && notification.actions && index >= 0 && index < notification.actions.length) {
                notification.actions[index].invoke();
            }
        }

        readonly property date time: new Date()
        readonly property string timeStr: time.toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
        })

        readonly property Connections conn: Connections {
            target: notifComponent.notification ? notifComponent.notification.Retainable : null
            function onDropped(): void {
                root.notificationClosed(notifComponent);
                const index = root.activeNotifications.indexOf(notifComponent);
                if (index > -1) {
                    root.activeNotifications.splice(index, 1);
                }
                notifComponent.destroy(500);
            }
        }
    }

    Component {
        id: notifComp
        Notif {}
    }
}

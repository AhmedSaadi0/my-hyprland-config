// NotifManager.qml
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // -------------------------------------------------------------------
    // --- Public API for UI Components ---
    // -------------------------------------------------------------------

    // 1. A live list of all active notification objects.
    // This can be used by a UI to display a list of all current notifications.
    property list<QtObject> activeNotifications: []

    // 2. A convenience property that reflects the number of active notifications.
    // UI elements like badges can bind directly to this property.
    // It's an alias, so it automatically updates when 'activeNotifications' changes.
    readonly property var notificationCount: activeNotifications.length

    // 3. Do Not Disturb mode state.
    property bool dndEnabled: false

    // --- Signals for the UI ---
    // Emitted when a new notification is ready to be displayed.
    signal notificationReceived(var smartNotifObject)

    // Emitted when a notification is confirmed to be closed/dismissed.
    signal notificationClosed(var smartNotifObject)

    // --- Public Functions for the UI ---
    // Dismisses all currently active notifications.
    function clearAllNotifs() {
        // We iterate over a copy because dismissing will modify the original list.
        const allSmartNotifs = [...root.activeNotifications];
        for (const notif of allSmartNotifs) {
            // Access the original notification and dismiss it.
            // This will trigger the onDropped signal for each.
            notif.notification.dismiss();
        }
    }

    // Toggles the Do Not Disturb state.
    function toggleDnd() {
        dndEnabled = !dndEnabled;
    }

    // -------------------------------------------------------------------
    // --- Internal Logic & Server Handling ---
    // -------------------------------------------------------------------

    // Process to play a sound effect for new notifications.
    Process {
        id: notificationSound
        command: ["paplay", ".config/quickshell/assets/audio/new-notification.mp3"]
    }

    // The core notification server from Quickshell.
    NotificationServer {
        id: notifServer

        // Server capabilities
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        // This is triggered when a new notification arrives from any application.
        onNotification: originalNotif => {
            originalNotif.tracked = true;

            // Create our custom "smart" notification object that wraps the original.
            const newSmartNotif = notifComp.createObject(root, {
                notification: originalNotif
            });

            // Add the new notification to our live list.
            root.activeNotifications.push(newSmartNotif);

            // Inform the UI about the new notification.
            root.notificationReceived(newSmartNotif);

            // Play sound if Do Not Disturb is off.
            if (!root.dndEnabled) {
                notificationSound.running = true;
            }
        }
    }

    // --- The Smart "Notif" Object Definition ---
    // This is a template for our custom notification objects. It adds features
    // like a timestamp and simplifies property access for the UI.
    component Notif: QtObject {
        id: notifComponent

        // The original notification object from the server.
        required property Notification notification

        // Properties for direct and easy access in the UI delegate.
        readonly property string summary: notification ? notification.summary : ""
        readonly property string body: notification ? notification.body : ""
        readonly property string appIcon: notification ? notification.appIcon : ""
        readonly property string appName: notification ? notification.appName : ""
        readonly property string image: notification ? notification.image : ""
        readonly property int id: notification ? notification.id : 0

        // Computed properties for added value.
        readonly property date time: new Date()
        readonly property string timeStr: time.toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
        })

        // Self-management logic: This block listens to the lifecycle of the original notification.
        readonly property Connections conn: Connections {
            target: notifComponent.notification ? notifComponent.notification.Retainable : null

            // onDropped is emitted when the notification is dismissed by any means
            // (user click, timeout, or programmatically).
            function onDropped(): void {
                // Inform the UI that this specific notification has closed.
                root.notificationClosed(notifComponent);

                // Find this notification in our live list and remove it.
                const index = root.activeNotifications.indexOf(notifComponent);
                if (index > -1) {
                    root.activeNotifications.splice(index, 1);
                }

                // Schedule this object for garbage collection to prevent memory leaks.
                notifComponent.destroy(500); // 500ms delay for safety.
            }
        }
    }

    // A factory component for creating instances of our "Notif" object.
    Component {
        id: notifComp
        Notif {}
    }
}

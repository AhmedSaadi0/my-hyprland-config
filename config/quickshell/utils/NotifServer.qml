pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: notif

    property bool dndEnabled: false
    property int notifCount: notifServer.trackedNotifications.values.length
    property ScriptModel notifications: serverNotifications
    property NotificationServer server: notifServer

    function clearNotifs() {
        [...notifServer.trackedNotifications.values].forEach(elem => {
            elem.dismiss();
        });
    }

    NotificationServer {
        id: notifServer

        // actionIconsSupported: true
        // actionsSupported: true
        // bodyHyperlinksSupported: true
        // bodyImagesSupported: true
        // bodyMarkupSupported: true
        // bodySupported: true
        // imageSupported: true
        // persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            console.info(n);
        }
    }

    ScriptModel {
        id: serverNotifications
        values: [...notifServer.trackedNotifications.values].reverse()
    }
}

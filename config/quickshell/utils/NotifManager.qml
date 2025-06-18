pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: notif

    property bool dndEnabled: false

    signal notificationReceived(var notifObj)

    function clearNotifs() {
        [...notifServer.trackedNotifications.values].forEach(elem => {
            elem.dismiss();
        });
    }

    function getCurrentNotifications() {
        return [...notifServer.trackedNotifications.values].map(n => ({
                    id: n.id,
                    summary: n.summary,
                    body: n.body,
                    appName: n.appName
                })).reverse();
    }

    NotificationServer {
        id: notifServer

        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;

            const now = new Date();

            n.createdAt = now;
            n.time = now.toLocaleTimeString('en-US');

            notif.notificationReceived(n);
        }
    }

    ScriptModel {
        id: serverNotifications
        values: [...notifServer.trackedNotifications.values].reverse()
    }
}

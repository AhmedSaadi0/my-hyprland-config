// components/notifications/NotificationData.qml
import QtQuick

QtObject {
    id: root

    property string appName
    property string summary
    property string body
    property string image
    property string timeStr
    property var displayActions

    property var originalNotif: null
    readonly property bool isValid: originalNotif !== null

    onOriginalNotifChanged: {
        if (originalNotif) {
            originalNotif.destroying.connect(onOriginalDestroyed);
        }
    }

    function onOriginalDestroyed() {
        if (originalNotif) {
            originalNotif.destroying.disconnect(onOriginalDestroyed);
        }
        originalNotif = null;
    }

    function invokeAction(index) {
        if (isValid) {
            originalNotif.invokeAction(index);
        } else {
            console.warn("Attempted to invoke action on a closed notification.");
        }
    }

    function dismiss() {
        if (isValid) {
            originalNotif.notification.dismiss();
        } else {
            console.warn("Attempted to dismiss a closed notification.");
        }
    }
}

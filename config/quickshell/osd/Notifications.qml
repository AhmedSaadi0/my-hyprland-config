// ToastNotificationHandler.qml
import QtQuick
import Quickshell
import QtQuick.Layouts
import "root:/services"
import "root:/components/notifications"

PanelWindow {
    id: root

    implicitWidth: popupContainer.implicitWidth + 20
    implicitHeight: popupContainer.implicitHeight + 20
    color: "transparent"
    visible: popupModel.count > 0

    exclusionMode: ExclusionMode.Ignore

    margins {
        bottom: 30
        left: 30
    }

    anchors {
        bottom: true
        left: true
    }

    ListModel {
        id: popupModel
    }

    Connections {
        target: NotifManager
        function onNotificationReceived(smartNotifObject) {
            if (!NotifManager.dndEnabled) {
                popupModel.insert(0, {
                    "smartNotif": smartNotifObject
                });
            }
        }
        function onNotificationClosed(smartNotifObject) {
            // Find and remove matching popup if it exists
            for (let i = 0; i < popupModel.count; ++i) {
                if (popupModel.get(i).smartNotif === smartNotifObject) {
                    popupModel.remove(i);
                    break;
                }
            }
        }
    }

    // --- Popup Component Definition ---
    component ToastNotificationPopup: Item {
        id: toastRoot
        property var notification
        signal requestRemove

        width: notificationItem.width
        height: notificationItem.height

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
                target: toastRoot
                opacity: 1
                scale: 1.0
            }
        }

        Timer {
            id: hideTimer
            interval: 3000
            repeat: false
            onTriggered: showing = false
        }

        HoverHandler {
            // anchors.fill: parent
            onHoveredChanged: {
                if (hovered)
                    hideTimer.stop();
                else if (toastRoot.showing)
                    hideTimer.start();
            }
        }

        onShowingChanged: {
            if (!showing) {
                removeDelay.start();
            }
        }

        Timer {
            id: removeDelay
            interval: 300
            repeat: false
            onTriggered: toastRoot.requestRemove()
        }

        Component.onCompleted: {
            showing = true;
            hideTimer.start();
        }

        NotificationItem {
            id: notificationItem
            width: 350
            notification: toastRoot.notification

            onDismissClicked: {
                hideTimer.stop();
                showing = false;
            }

            onActionInvoked: index => {
                if (toastRoot.notification) {
                    toastRoot.notification.invokeAction(index);
                }
                hideTimer.stop();
                showing = false;
            }
        }
    }

    // --- Layout for Popups ---
    ColumnLayout {
        id: popupContainer
        spacing: 8

        Repeater {
            model: popupModel

            delegate: ToastNotificationPopup {
                notification: model.smartNotif
                onRequestRemove: {
                    if (model.index >= 0 && model.index < popupModel.count) {
                        popupModel.remove(model.index);
                    }
                }
            }
        }
    }
}

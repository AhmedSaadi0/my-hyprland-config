// ToastNotificationHandler.qml
import QtQuick
import Quickshell
// import QtQuick.Layouts
import Quickshell.Wayland

import "root:/services"
import "root:/components/notifications"
import "root:/components"
import "root:/themes"

PanelWindow {
    id: root

    implicitWidth: 370
    implicitHeight: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight

    color: "transparent"
    visible: popupModel.count > 0

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "NibrasShell:notificationPopup"
    WlrLayershell.layer: WlrLayer.Overlay
    // WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    // mask: Region {}

    margins {
        bottom: 30
        right: 30
        top: 70
        left: 30
    }

    anchors {
        bottom: true
        right: true
        top: true
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

        opacity: 0
        x: 100

        Component.onCompleted: {
            show();
            hideTimer.start();
        }

        function show() {
            xAnimation.to = 0;
            opacityAnimation.to = 1;
            parallelShowAnimation.start();
        }

        function hide() {
            hideTimer.stop();
            xAnimation.to = toastRoot.width;
            opacityAnimation.to = 0;
            parallelHideAnimation.start();
        }

        layer.enabled: true
        layer.effect: Shadow {}

        ParallelAnimation {
            id: parallelShowAnimation

            NumberAnimation {
                id: xAnimation
                target: toastRoot
                property: "x"
                duration: 400
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: opacityAnimation
                target: toastRoot
                property: "opacity"
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        ParallelAnimation {
            id: parallelHideAnimation
            onStopped: toastRoot.requestRemove()

            NumberAnimation {
                target: toastRoot
                property: "x"
                to: toastRoot.width
                duration: 400
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: toastRoot
                property: "opacity"
                to: 0
                duration: 350
                easing.type: Easing.InQuad
            }
        }

        Timer {
            id: hideTimer
            interval: 3000
            repeat: false
            onTriggered: hide()
        }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    hideTimer.stop();
                } else {
                    hideTimer.restart();
                }
            }
        }

        NotificationItem {
            id: notificationItem
            width: 350
            notification: toastRoot.notification
            onDismissClicked: hide()
            theme: ThemeManager.selectedTheme
            onActionInvoked: index => {
                if (toastRoot.notification) {
                    toastRoot.notification.invokeAction(index);
                }
                hide();
            }
        }
    }

    ListView {
        id: popupContainer
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight

        spacing: 8
        model: popupModel
        interactive: false
        clip: true

        // anchors.top: parent.top

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // انتقال عند إضافة عنصر
        add: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1.0
                    duration: 300
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.8
                    to: 1.0
                    duration: 300
                    easing.type: Easing.OutBack
                }
            }
        }

        // انتقال عند إزالة عنصر
        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 300
                }
                NumberAnimation {
                    property: "scale"
                    to: 0.8
                    duration: 300
                    easing.type: Easing.InCubic
                }
            }
        }

        delegate: ToastNotificationPopup {
            width: popupContainer.width
            notification: model.smartNotif

            onRequestRemove: {
                if (model.index >= 0 && model.index < popupModel.count) {
                    popupModel.remove(model.index);
                }
            }
        }
    }
}

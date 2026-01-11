import Quickshell
import QtQuick
import Quickshell.Wayland
import "root:/windows/leftwindow/dashboard" as DashboardComponents
import "root:/config/EventNames.js" as Events
import "root:/services" // For EventBus

PanelWindow {
    id: root

    // Make the window cover the entire screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Crucial: Tell the window manager NOT to reserve space for this window.
    // It will float over your desktop/apps.
    exclusionMode: ExclusionMode.Ignore

    // Transparent background
    color: "transparent"
    visible: false

    // 1. Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    // 2. The Power Options Card
    PowerOptions {
        id: powerCard
        anchors.centerIn: parent
        width: 320
        height: implicitHeight > 0 ? implicitHeight : 200

        // Prevent clicking the card from closing the window
        MouseArea {
            anchors.fill: parent
            z: -1  // <--- ADD THIS LINE
            propagateComposedEvents: false
            onClicked: mouse.accepted = true
        }
    }

    // 3. Logic to toggle visibility
    Component.onCompleted: {
        EventBus.on(Events.TOGGLE_POWER_MENU, function() {
            root.visible = !root.visible;
        });
    }
}
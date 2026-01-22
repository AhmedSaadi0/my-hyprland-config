// windows/poweroption/PowerMenuWindow.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "root:/windows/leftwindow/dashboard" as DashboardComponents
import "root:/config/EventNames.js" as Events
import "root:/services"
import "root:/themes"
import "root:/config"

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "NibrasShell:logout"
    WlrLayershell.layer: WlrLayer.Overlay

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: ThemeManager.selectedTheme.colors.topbarColor.alpha(0.7)
    visible: false

    Item {
        id: keyboardHandler
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: event => {
            root.visible = false;
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.visible = false;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    PowerOptions {
        id: powerCard
        anchors.centerIn: parent
        width: 320

        MouseArea {
            Layout.fillHeight: true
            Layout.fillWidth: true
            z: -1
            propagateComposedEvents: false
            onClicked: mouse.accepted = true
        }

        onClose: root.visible = false
    }

    // onVisibleChanged: {
    //     if (visible) {
    //         keyboardHandler.forceActiveFocus();
    //         console.log("Window visible, forcing focus...");
    //     }
    // }

    Component.onCompleted: {
        EventBus.on(Events.TOGGLE_POWER_MENU, function () {
            root.visible = !root.visible;
        });
    }
}

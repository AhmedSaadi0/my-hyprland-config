import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../themes"

PanelWindow {
    id: panelWindow
    height: 900
    width: 360
    visible: false

    margins.top: 10
    margins.left: 10

    color: "transparent"

    property var showAnimationType: Easing.InOutExpo
    property var hideAnimationType: Easing.InOutExpo

    property int showAnimationDuration: 400
    property int hideAnimationDuration: 400

    anchors {
        top: true
        left: true
    }

    Rectangle {
        id: contentContainer
        width: parent.width
        height: parent.height - 10
        color: palette.window
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        border {
            color: palette.accent
            width: 2
        }

        RowLayout {
            anchors.fill: parent
        }
    }

    // --- Define the animations ---
    PropertyAnimation {
        id: showAnimation
        target: contentContainer // Animate the inner rectangle
        property: "y"
        to: 0 // Animate to y=0 (visible position relative to window top)
        duration: panelWindow.showAnimationDuration
        easing.type: panelWindow.showAnimationType
        onStopped: {
            panelWindow.visible = true;
        }
        onStarted: {
            panelWindow.visible = true;
        }
    }

    PropertyAnimation {
        id: hideAnimation
        target: contentContainer // Animate the inner rectangle
        property: "y"
        to: -contentContainer.height // Animate to y = -height (off-screen above)
        duration: panelWindow.hideAnimationDuration
        easing.type: panelWindow.hideAnimationType
        onStarted: {
            panelWindow.visible = true;
        }
        onStopped: {
            panelWindow.visible = false;
        }
    }

    Component.onCompleted: {
        contentContainer.y = -contentContainer.height;
        if (visible) {
            open();
        }
    }

    function open() {
        panelWindow.visible = true;
        hideAnimation.stop();
        showAnimation.start();
    }

    function close() {
        showAnimation.stop();
        hideAnimation.start();
    // panelWindow.visible = true;
    }
}

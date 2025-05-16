import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../themes"
import "../../components"

PanelWindow {
    id: leftPanel
    height: ThemeManager.selectedTheme.dimensions.menuHeight
    width: ThemeManager.selectedTheme.dimensions.menuWidth
    visible: false

    margins.top: 0
    margins.left: 6

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
        width: parent.width - 10
        height: parent.height - 10
        color: palette.window
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        layer.enabled: true
        layer.effect: Shadow {
            // radius: 9
            radius: 9
            color: palette.shadow.alpha(0.5)
            spread: 0
            samples: 15
            verticalOffset: 2
            horizontalOffset: 2
        }

        border {
            color: palette.accent
            width: 2
        }

        // RowLayout {
        //     anchors.fill: parent
        // }

        Header {
            id: menuHeader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            // radius: ThemeManager.selectedTheme.dimensions.elementRadius
        }

        MenuSelectorBar {
            height: 600
            // width: parent.width
            anchors {
                // top: menuHeader.bottom
                left: contentContainer.left
                right: contentContainer.right
                bottom: contentContainer.bottom
                leftMargin: 15
                rightMargin: 16
                bottomMargin: 15
                topMargin: 15
            }
        }
    }

    // --- Define the animations ---
    PropertyAnimation {
        id: showAnimation
        target: contentContainer // Animate the inner rectangle
        property: "y"
        to: 0 // Animate to y=0 (visible position relative to window top)
        duration: leftPanel.showAnimationDuration
        easing.type: leftPanel.showAnimationType
        onStopped: {
            leftPanel.visible = true;
        }
        onStarted: {
            leftPanel.visible = true;
        }
    }

    PropertyAnimation {
        id: hideAnimation
        target: contentContainer // Animate the inner rectangle
        property: "y"
        to: -contentContainer.height // Animate to y = -height (off-screen above)
        duration: leftPanel.hideAnimationDuration
        easing.type: leftPanel.hideAnimationType
        onStarted: {
            leftPanel.visible = true;
        }
        onStopped: {
            leftPanel.visible = false;
        }
    }

    Component.onCompleted: {
        contentContainer.y = -contentContainer.height;
        if (visible) {
            open();
        }
    }

    function open() {
        leftPanel.visible = true;
        hideAnimation.stop();
        showAnimation.start();
    }

    function close() {
        showAnimation.stop();
        hideAnimation.start();
        leftPanel.visible = true;
    }
}

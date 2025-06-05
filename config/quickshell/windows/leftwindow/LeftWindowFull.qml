import Quickshell

import QtQuick

import "../../themes"
import "../../components"

PanelWindow {
    id: root

    // width: 300
    width: ThemeManager.selectedTheme.dimensions.menuWidth

    color: "transparent"

    property var showAnimationType: Easing.OutExpo
    property var hideAnimationType: Easing.InExpo
    // property var showAnimationType: Easing.OutQuint
    // property var hideAnimationType: Easing.InQuint

    property int showAnimationDuration: 300
    property int hideAnimationDuration: 300

    anchors {
        top: true
        left: true
        bottom: true
    }

    Rectangle {
        id: contentContainer
        width: parent.width
        height: parent.height
        color: palette.window
        // radius: ThemeManager.selectedTheme.dimensions.elementRadius

        // layer.enabled: true
        // layer.effect: Shadow {
        //     // radius: 9
        //     radius: 9
        //     color: palette.shadow.alpha(0.5)
        //     spread: 0
        //     samples: 15
        //     verticalOffset: 2
        //     horizontalOffset: 2
        // }

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
            // height: 600
            // width: parent.width
            anchors {
                top: menuHeader.bottom
                left: contentContainer.left
                right: contentContainer.right
                bottom: contentContainer.bottom
                leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 2
            }
        }
    }

    // --- Define the animations ---
    PropertyAnimation {
        id: showAnimation
        target: contentContainer // Animate the inner rectangle
        property: "x"
        to: 0 // Animate to y=0 (visible position relative to window top)
        duration: root.showAnimationDuration
        easing.type: root.showAnimationType
        onStopped: {
            root.visible = true;
        }
        onStarted: {
            root.visible = true;
        }
    }

    PropertyAnimation {
        id: hideAnimation
        target: contentContainer // Animate the inner rectangle
        property: "x"
        to: -contentContainer.width // Animate to y = -height (off-screen above)
        duration: root.hideAnimationDuration
        easing.type: root.hideAnimationType
        onStarted: {
            root.visible = true;
        }
        onStopped: {
            root.visible = false;
        }
    }

    Component.onCompleted: {
        contentContainer.x = -contentContainer.width;
        if (visible) {
            open();
        }
    }

    function open() {
        // root.visible = true;
        hideAnimation.stop();
        showAnimation.start();
    }

    function close() {
        showAnimation.stop();
        hideAnimation.start();
    // root.visible = true;
    }
}

import Quickshell
import QtQuick
import "../../themes"
import "../../components"

PanelWindow {
    id: root

    // --- State and Configuration ---

    // 1. A SINGLE, CLEAR PROPERTY TO DRIVE THE STATE
    // We use this instead of trying to manage 'visible' directly.
    property bool isShown: false

    width: ThemeManager.selectedTheme.dimensions.menuWidth
    color: "transparent"

    // To prevent the window from being interactive when hidden (e.g., catching mouse clicks)
    // enabled: isShown

    // We can simplify this to a single duration property
    property var animationEasing: Easing.InOutSine
    property int animationDuration: 300

    anchors {
        top: true
        left: true
        bottom: true
    }

    // --- Main Content (The Animation Controller) ---

    Rectangle {
        id: contentContainer
        width: parent.width
        height: parent.height
        color: palette.window
        // enabled: root.isShown

        // --- Children (Unchanged) ---
        Header {
            id: menuHeader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MenuSelectorBar {
            anchors {
                top: menuHeader.bottom
                left: contentContainer.left
                right: contentContainer.right
                bottom: contentContainer.bottom
                leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 1.6
            }
        }

        // --- THE NEW ANIMATION LOGIC ---

        transform: Scale {
            id: containerScale
            origin.x: 0 // Scale from the left edge
        }

        states: [
            State {
                name: "SHOWN"
                when: root.isShown
                PropertyChanges {
                    target: containerScale
                    scale: 1.0
                }
                PropertyChanges {
                    target: contentContainer
                    x: 0
                    opacity: 1.0
                }
            },
            State {
                name: "HIDDEN"
                when: !root.isShown
                // MORE PRONOUNCED VALUES:
                // Start smaller and further to the left.
                PropertyChanges {
                    target: containerScale
                    scale: 0.90
                }
                PropertyChanges {
                    target: contentContainer
                    x: -40
                    opacity: 0.0
                }
            }
        ]

        transitions: [
            Transition {
                // To make the pop feel snappier, let's use a slightly different easing curve.
                // Easing.OutQuint is steeper than OutCubic, giving it more initial velocity.

                // Animate all properties at once.
                NumberAnimation {
                    easing.type: animationEasing
                    duration: root.animationDuration // Can maybe even reduce this to 280ms
                    properties: "x, opacity, scale"
                }
            }
        ]

        // IMPORTANT: In this simplified transition, you need to tell the NumberAnimation
        // WHERE to animate the 'scale' property. We do that by binding the 'target'.
        // This is a powerful shorthand in transitions.
        Binding {
            target: containerScale
            property: "scale"
            value: contentContainer.state === "SHOWN" ? 1.0 : 0.90
        }
    }

    // --- Visibility and Lifetime Management ---
    // This is how we safely manage the window's actual visibility
    // without causing flicker. It is now driven by our isShown property.
    onIsShownChanged: {
        if (isShown) {
            // If we want to show the panel, make the window visible FIRST,
            // then the animation will play inside it.
            root.visible = true;
        }
    }

    // We connect to the transition's "running" property.
    // When the animation from any state to the HIDDEN state is finished,
    // we can safely hide the window.
    Connections {
        target: contentContainer.transitions[0] // The one and only transition
        function onRunningChanged() {
            if (!target.running && !root.isShown) {
                root.visible = false;
            }
        }
    }

    // The initial state on startup.
    Component.onCompleted: {
        // Start with the window invisible if it's not meant to be shown.
        if (!isShown) {
            root.visible = false;
        }
    }

    // --- Public Functions (Now greatly simplified) ---
    function open() {
        isShown = true;
    }

    function close() {
        isShown = false;
    }
}

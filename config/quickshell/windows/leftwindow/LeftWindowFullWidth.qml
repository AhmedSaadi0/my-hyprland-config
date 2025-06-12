import Quickshell
import QtQuick
import "../../themes"
import "../../components"

PanelWindow {
    id: root

    // --- State and Configuration ---

    // 1. A new property to hold the full, expanded width.
    // This makes the code cleaner than referencing the theme manager everywhere.
    readonly property int fullWidth: ThemeManager.selectedTheme.dimensions.menuWidth

    // 2. A state property to control whether the panel is open or closed.
    // This is the new "source of truth" for the panel's state.
    property bool expanded: false // Start closed by default

    // 3. The width is now bound to our state. It will be either the full
    // width or 2px, depending on the `expanded` property.
    width: expanded ? fullWidth : 2

    // Animation properties remain the same
    property var showAnimationType: Easing.OutExpo
    property var hideAnimationType: Easing.InExpo
    property int showAnimationDuration: 300
    property int hideAnimationDuration: 300

    color: "transparent"

    anchors {
        top: true
        left: true
        bottom: true
    }

    // --- Main Content ---

    Rectangle {
        id: contentContainer
        width: parent.width
        height: parent.height
        color: palette.window

        // 4. IMPORTANT: Add clipping. This prevents the content from
        // drawing outside the bounds of the container when it's shrinking.
        clip: true

        Header {
            id: menuHeader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            // 5. To prevent the header from looking weird when collapsed,
            // we can make its visibility depend on the panel being wide enough.
            visible: parent.width > 50 // Or some other threshold
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
            // 6. Same as the Header, hide the content when collapsed.
            visible: parent.width > 50
        }
    }

    // --- Animation Logic ---

    // 7. Replaced the two separate PropertyAnimation items with a single Behavior.
    // This object specifies HOW the 'width' property should animate whenever its
    // value changes. It's a much more declarative and robust approach.
    Behavior on width {
        NumberAnimation {
            // Dynamically choose duration and easing based on whether we are expanding or collapsing.
            duration: root.expanded ? root.showAnimationDuration : root.hideAnimationDuration
            easing.type: root.expanded ? root.showAnimationType : root.hideAnimationType
        }
    }

    // The old PropertyAnimations and Component.onCompleted logic are no longer needed.

    // --- Public Functions ---

    // 8. The open/close functions are now simplified to just change the state.
    // The Behavior on 'width' will automatically trigger the correct animation.
    function open() {
        expanded = true;
    }

    function close() {
        expanded = false;
    }
}

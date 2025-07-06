import QtQuick
// import QtQuick.Controls

import "../themes"

Item {
    id: buttonGroup

    // --- Public API ---
    property alias model: buttonRepeater.model
    property int currentIndex: -1
    property int itemSpacing: 10
    property int buttonHeight: 30

    Rectangle {
        id: highlightIndicator

        // --- MODIFIED ---
        // Set x to 0 and width to the full width of the parent.
        // This makes the highlight match the button geometry perfectly.
        x: 0
        width: buttonGroup.width

        height: buttonGroup.buttonHeight
        y: buttonGroup.currentIndex * (buttonGroup.buttonHeight + buttonGroup.itemSpacing)

        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: ThemeManager.selectedTheme.colors.primary
        opacity: buttonGroup.currentIndex !== -1 ? 1.0 : 0.0

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }

    Column {
        id: buttonContainer
        anchors.fill: parent
        spacing: buttonGroup.itemSpacing

        Repeater {
            id: buttonRepeater
            // model is aliased from the parent

            delegate: MButton {
                width: buttonContainer.width // This was already correct
                height: buttonGroup.buttonHeight

                // Overrides remain the same
                isActive: buttonGroup.currentIndex === index
                normalBackground: "transparent"
                activeBackground: "transparent"
                hoveredBackground: isActive ? "transparent" : ThemeManager.selectedTheme.colors.primary

                text: model.icon
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 15

                onClicked: {
                    var newIndex = (buttonGroup.currentIndex === index) ? -1 : index;
                    buttonGroup.currentIndex = newIndex;
                    // buttonGroup.currentIndexChanged(newIndex);
                }
            }
        }
    }
}

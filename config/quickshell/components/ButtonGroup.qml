import QtQuick
// import QtQuick.Controls

import "root:/themes"

Item {
    id: buttonGroup

    // --- Public API ---
    property alias model: buttonRepeater.model
    property int currentIndex: -1
    property int itemSpacing: 10
    property int buttonHeight: 30

    Rectangle {
        id: highlightIndicator
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

            // --- DELEGATE MODIFIED FOR BADGE ---
            delegate: Item {
                // This Item is a container for the button and the badge
                width: buttonContainer.width
                height: buttonGroup.buttonHeight

                // The original MButton is now placed inside the container
                MButton {
                    id: button
                    anchors.fill: parent // Fill the container

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
                    }
                }

                // --- BADGE ADDED HERE ---
                // This Rectangle is the notification badge
                Rectangle {
                    id: badgeCircle
                    width: 14
                    height: 14
                    radius: 7 // Make it a circle
                    color: ThemeManager.selectedTheme.colors.primary

                    // Crucial: Only show if notificationCount is defined and > 0
                    visible: model.notificationCount && model.notificationCount > 0

                    // Position in the top-right corner of the button area
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 2
                    anchors.rightMargin: 2

                    // The text number inside the badge
                    Text {
                        text: model.notificationCount
                        anchors.centerIn: parent
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        font.bold: true
                        font.pixelSize: 8
                    }
                }
            }
        }
    }
}

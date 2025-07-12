import QtQuick
// import QtQuick.Controls

import "root:/themes"
import "root:/utils/helpers.js" as Helper

Item {
    id: buttonGroup

    // --- Public API ---
    property alias model: buttonRepeater.model
    property int currentIndex: -1
    property int itemSpacing: 10
    property int buttonHeight: 30
    property bool useHand: false

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

                    hoverEnabled: true
                    // تغيير شكل المؤشر بناءً على قيمة المتغير useHand
                    cursorShape: buttonGroup.useHand ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                // --- BADGE ADDED HERE ---
                // This Rectangle is the notification badge

                // --- BADGE ADDED HERE ---
                Rectangle {
                    id: badgeCircle
                    width: 15
                    height: 15
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    color: ThemeManager.selectedTheme.colors.primary
                    opacity: 0.0
                    scale: 0.7
                    visible: model.notificationCount && model.notificationCount > 0

                    // Position in the top-right corner of the button area
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 2
                    anchors.rightMargin: 2

                    // Animation for visibility and scale on appear
                    states: State {
                        name: "visible"
                        when: badgeCircle.visible
                        PropertyChanges {
                            target: badgeCircle
                            opacity: 1.0
                            scale: 1.0
                        }
                    }

                    transitions: Transition {
                        NumberAnimation {
                            properties: "opacity,scale"
                            duration: 850
                            easing.type: Easing.OutElastic
                        }
                    }

                    // النص داخل الـ badge
                    Text {
                        id: badgeText
                        text: model.notificationCount
                        anchors.centerIn: parent
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        // color: Helper.getAccurteTextColor(ThemeManager.selectedTheme.colors.primary)
                        font.bold: true
                        font.pixelSize: 8

                        property int oldCount: -1

                        onTextChanged: function (text) {
                            if (oldCount !== -1 && oldCount !== text) {
                                textAnimation.restart();
                            }
                            oldCount = text;
                        }

                        // تعريف الأنميشن عند التغيير
                        SequentialAnimation {
                            id: textAnimation
                            NumberAnimation {
                                target: badgeText
                                property: "scale"
                                to: 1.3
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: badgeText
                                property: "scale"
                                to: 1.0
                                duration: 120
                                easing.type: Easing.OutBack
                            }
                        }
                    }
                }
            }
        }
    }
}

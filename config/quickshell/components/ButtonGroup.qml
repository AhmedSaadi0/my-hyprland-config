import QtQuick

import "root:/utils/helpers.js" as Helper

Item {
    id: root

    property alias model: buttonRepeater.model
    property int currentIndex: -1
    property int itemSpacing: 10
    property int buttonHeight: 30
    property bool useHand: false

    property var theme

    implicitWidth: 50
    implicitHeight: buttonContainer.implicitHeight

    Rectangle {
        id: highlightIndicator

        width: root.width
        height: root.buttonHeight
        y: root.currentIndex * (root.buttonHeight + root.itemSpacing)

        radius: root.theme ? root.theme.dimensions.elementRadius : 8
        color: root.theme ? root.theme.colors.primary : "blue"
        opacity: root.currentIndex !== -1 ? 1.0 : 0.0

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
        spacing: root.itemSpacing

        Repeater {
            id: buttonRepeater

            delegate: Item {
                width: buttonContainer.width
                height: root.buttonHeight

                MButton {
                    id: button
                    anchors.fill: parent

                    text: model.icon
                    activeText: model.activeIcon
                    isActive: root.currentIndex === index
                    hoverEnabled: true

                    // استخدام مباشر لقيم السمة مع قيم افتراضية
                    font.family: root.theme ? root.theme.typography.iconFont : "sans-serif"
                    font.pixelSize: 15

                    normalBackground: "transparent"
                    activeBackground: "transparent"
                    hoveredBackground: isActive ? "transparent" : (root.theme ? root.theme.colors.primary : "blue")

                    cursorShape: root.useHand ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        root.currentIndex = (root.currentIndex === index) ? -1 : index;
                    }
                }

                Rectangle {
                    id: badgeCircle

                    width: 15
                    height: 15

                    // استخدام مباشر لقيم السمة مع قيم افتراضية
                    radius: root.theme ? root.theme.dimensions.elementRadius : 8
                    color: root.theme ? root.theme.colors.primary : "blue"
                    visible: model.notificationCount && model.notificationCount > 0
                    opacity: 0.0
                    scale: 0.7

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 2
                    anchors.rightMargin: 2

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

                    Text {
                        id: badgeText

                        text: model.notificationCount
                        // استخدام مباشر لقيم السمة مع قيم افتراضية
                        color: root.theme ? Helper.getAccurteTextColor(root.theme.colors.primary) : "white"
                        font.bold: true
                        font.pixelSize: 8

                        anchors.centerIn: parent
                        property int oldCount: -1

                        onTextChanged: function () {
                            if (oldCount !== -1 && oldCount !== text) {
                                textAnimation.restart();
                            }
                            oldCount = text;
                        }

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

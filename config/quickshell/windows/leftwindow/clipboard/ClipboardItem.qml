// windows/leftwindow/clipboard/ClipboardItem.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/services"
import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"

Item {
    id: wrapper

    // -- Properties & Logic --
    property var lv: ListView.view
    property bool isExpanded: false

    // Check if item matches search text
    property bool matchesSearch: {
        if (!lv.currentSearchText || lv.currentSearchText === "")
            return true;
        return model.text.toLowerCase().indexOf(lv.currentSearchText.toLowerCase()) !== -1;
    }

    // -- Layout & Visibility --
    width: lv.width
    height: matchesSearch ? (isExpanded ? contentLayout.implicitHeight + 24 : 62) : 0
    visible: height > 0
    clip: true

    transform: Translate {
        x: wrapper.lv.pullOffset + wrapper.lv.shockOffset
    }

    Behavior on height {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuart
        }
    }

    // -- Resources --
    Timer {
        id: collapseTimer
        interval: 150
        onTriggered: wrapper.isExpanded = false
    }

    // -- Main Content --
    Item {
        id: swipeContainer

        width: parent.width
        height: wrapper.height
        anchors.top: parent.top
        visible: wrapper.matchesSearch

        Behavior on x {
            enabled: !dragArea.drag.active
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.0
            }
        }

        // 1. Hover Controller (High Z-index)
        MouseArea {
            id: hoverTrigger
            anchors.fill: parent
            z: 10
            hoverEnabled: true
            propagateComposedEvents: true

            // Pass through clicks to underlying layers
            onPressed: mouse => mouse.accepted = false
            onReleased: mouse => mouse.accepted = false
            onClicked: mouse => mouse.accepted = false
            onDoubleClicked: mouse => mouse.accepted = false
            onPressAndHold: mouse => mouse.accepted = false

            onEntered: {
                collapseTimer.stop();
                wrapper.isExpanded = true;
            }
            onExited: collapseTimer.start()
        }

        // 2. Drag/Swipe Controller
        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: false

            drag.target: swipeContainer
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: 600
            drag.filterChildren: true

            onPressed: wrapper.lv.userIsDragging = true

            onPositionChanged: {
                if (drag.active) {
                    var tension = Math.max(0, swipeContainer.x / 12);
                    wrapper.lv.pullOffset = Math.min(tension, 30);
                }
            }

            onReleased: {
                wrapper.lv.userIsDragging = false;
                // Swipe to delete logic
                if (swipeContainer.x > 120) {
                    wrapper.lv.pullOffset = 0;
                    swipeContainer.x = 600;
                    wrapper.lv.triggerSway();
                    ClipboardService.remove(index, clipId);
                } else {
                    swipeContainer.x = 0;
                    wrapper.lv.pullOffset = 0;
                }
            }

            onClicked: {
                if (!drag.active) {
                    ClipboardService.activate(clipId);
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                }
            }
        }

        // 3. Visual Content
        Rectangle {
            id: req
            anchors.fill: parent

            // Visual feedback
            opacity: 1 - (swipeContainer.x / 300)
            color: (wrapper.isExpanded || dragArea.pressed) ? ThemeManager.selectedTheme.colors.secondary.alpha(0.1) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            property color accColor: {
                switch (model.type) {
                case 1:
                    return ThemeManager.selectedTheme.colors.secondary;
                case 2:
                    return ThemeManager.selectedTheme.colors.tertiary;
                case 4:
                    return ThemeManager.selectedTheme.colors.warning;
                default:
                    return ThemeManager.selectedTheme.colors.primary;
                }
            }

            // Bottom Separator
            Rectangle {
                width: parent.width - 40
                height: 1
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.05)
            }

            RowLayout {
                id: contentLayout
                anchors.fill: parent
                anchors.margins: 10
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 15

                // Accent Bar
                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    radius: 2
                    color: req.accColor
                }

                // Text Content
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    text: model.text
                    font.family: ThemeManager.selectedTheme.typography.bodyFont
                    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1

                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    maximumLineCount: wrapper.isExpanded ? 7 : 1
                }

                // Delete Button
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    Layout.rightMargin: 10
                    Layout.alignment: Qt.AlignTop
                    radius: 4
                    color: deleteMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.error.alpha(0.1) : "transparent"

                    Label {
                        anchors.centerIn: parent
                        text: "󰆴"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 18
                        color: ThemeManager.selectedTheme.colors.error
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ClipboardService.remove(index, clipId)
                    }
                }
            }
        }
    }
}

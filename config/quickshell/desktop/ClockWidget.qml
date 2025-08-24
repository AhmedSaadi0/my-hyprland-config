import QtQuick
import Quickshell
import QtQuick.Effects

import "root:/themes"
import "root:/components"

Item {
    id: clockComponent

    transformOrigin: Item.Center
    property bool editMode: false
    property bool isHovered: dragArea.hovered || resizeHandle.isHovered

    readonly property var clockLocal: Qt.locale(ThemeManager.selectedTheme.desktopClock.local)

    function syncWithTheme() {
        console.log("Syncing clock widget with current theme values.");

        visible = ThemeManager.selectedTheme.desktopClock.enabled;
        x = ThemeManager.selectedTheme.desktopClock.position.x;
        y = ThemeManager.selectedTheme.desktopClock.position.y;
        width = ThemeManager.selectedTheme.desktopClock.size.width;
        height = ThemeManager.selectedTheme.desktopClock.size.height;

        timeText.color = ThemeManager.selectedTheme.desktopClock.color;

        shadow.shadowColor = ThemeManager.selectedTheme.desktopClock.shadowColor;
        timeText.layer = ThemeManager.selectedTheme.desktopClock.shadowEnabled;
    // timeText.text = systemClock.date.toLocaleString(clockLocal, ThemeManager.selectedTheme.desktopClock.format);
    }

    Component.onCompleted: {
        syncWithTheme();
    }

    onEditModeChanged: {
        if (!editMode) {
            console.log("Exiting edit mode. Saving clock position and size.");
            const updatedData = {
                "_desktopClockPosition": Qt.point(clockComponent.x, clockComponent.y),
                "_desktopClockSize": Qt.size(clockComponent.width, clockComponent.height)
            };
            ThemeManager.updateAndApplyTheme(updatedData, true);
        }
    }

    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
            if (clockComponent.editMode) {
                return;
            }
            changePositionTimer.start();
        }
    }

    Timer {
        id: changePositionTimer
        interval: 800
        repeat: false
        onTriggered: {
            visualEffectAnimation.start();
            syncWithTheme();
        }
    }

    SequentialAnimation {
        id: visualEffectAnimation
        PropertyAnimation {
            target: clockComponent
            properties: "opacity, scale"
            to: 0.8
            duration: 150
            easing.type: Easing.InQuad
        }
        PropertyAnimation {
            target: clockComponent
            properties: "opacity, scale"
            to: 1.0
            duration: 600
            easing.type: Easing.OutElastic
            easing.amplitude: 1.2
            easing.period: 0.8
        }
    }

    Behavior on x {
        enabled: !clockComponent.editMode
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }
    Behavior on y {
        enabled: !clockComponent.editMode
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }

    Behavior on width {
        enabled: !clockComponent.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on height {
        enabled: !clockComponent.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InOutCubic
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        border.width: 3
        radius: 9
        visible: clockComponent.editMode
    }

    Text {
        id: timeText

        anchors.fill: parent
        anchors.margins: 20

        text: systemClock.date.toLocaleString(clockLocal, ThemeManager.selectedTheme.desktopClock.format)
        color: ThemeManager.selectedTheme.desktopClock.color
        font.family: ThemeManager.selectedTheme.desktopClock.font

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        // font.weight: Font.ExtraBold
        fontSizeMode: Text.Fit
        smooth: true

        font.pointSize: 500
        // minimumPixelSize: 20

        layer.enabled: ThemeManager.selectedTheme.desktopClock.shadowEnabled
        layer.effect: MultiEffect {
            id: shadow
            source: timeText
            shadowEnabled: true
            shadowColor: ThemeManager.selectedTheme.desktopClock.shadowColor
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }
    }

    Text {
        text: "⚙️"
        font.pixelSize: 25
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 11
        visible: clockComponent.editMode || clockComponent.isHovered

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: clockComponent.editMode = !clockComponent.editMode
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true

        property point startDragPos
        property point startComponentPos

        onPressed: mouse => {
            if (clockComponent.editMode) {
                startComponentPos = Qt.point(clockComponent.x, clockComponent.y);
                startDragPos = dragArea.mapToItem(null, mouse.x, mouse.y);
                mouse.accepted = true;
            }
        }

        onPositionChanged: mouse => {
            if (pressed && clockComponent.editMode) {
                var currentDragPos = dragArea.mapToItem(null, mouse.x, mouse.y);
                var delta = Qt.point(currentDragPos.x - startDragPos.x, currentDragPos.y - startDragPos.y);

                clockComponent.x = startComponentPos.x + delta.x;
                clockComponent.y = startComponentPos.y + delta.y;
            }
        }

        onReleased: {
            if (clockComponent.editMode) {
                const updatedPosition = {
                    "_desktopClockPosition": Qt.point(clockComponent.x, clockComponent.y)
                };
                ThemeManager.updateAndApplyTheme(updatedPosition, true);
            }
        }

        onDoubleClicked: clockComponent.editMode = !clockComponent.editMode
    }

    Rectangle {
        id: resizeHandle
        property bool isHovered: resizeMouseArea.hovered
        width: 20
        height: 20
        color: "white"
        radius: 10
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: -5
        visible: clockComponent.editMode

        MouseArea {
            id: resizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            property point startMousePos
            property size startComponentSize

            onPressed: {
                startMousePos = mapToItem(null, mouseX, mouseY);
                startComponentSize = Qt.size(clockComponent.width, clockComponent.height);
            }

            onPositionChanged: {
                if (pressed) {
                    var currentPos = mapToItem(null, mouseX, mouseY);
                    var delta = Qt.point(currentPos.x - startMousePos.x, currentPos.y - startMousePos.y);

                    var newWidth = Math.max(200, startComponentSize.width + delta.x);
                    var newHeight = Math.max(150, startComponentSize.height + delta.y);

                    clockComponent.width = newWidth;
                    clockComponent.height = newHeight;
                }
            }

            onReleased: {
                const updatedSize = {
                    "_desktopClockSize": Qt.size(clockComponent.width, clockComponent.height)
                };
                ThemeManager.updateAndApplyTheme(updatedSize, true);
            }
        }
    }
}

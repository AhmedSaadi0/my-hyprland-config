// desktop/ClockWidget.qml (النسخة النهائية)

import QtQuick
import Quickshell

import "root:/themes"
import "root:/components"

PanelWindow {
    id: clockRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    aboveWindows: false
    focusable: editMode
    exclusionMode: ExclusionMode.Ignore

    property bool editMode: false

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Item {
        id: clockContainer

        x: (clockRoot.width - width) / 2
        y: 40

        width: 500
        height: 300

        property bool isHovered: mouseArea.hovered

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "white"
            border.width: 2
            radius: 8
            visible: clockRoot.editMode
        }

        Column {
            anchors.centerIn: parent
            spacing: 0
            Text {
                id: timeText
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemClock.date.toLocaleString(Qt.locale(), "hh:mm AP")
                color: "white"
                font.pixelSize: 120
                font.weight: Font.Light
                layer.enabled: true
                layer.effect: Shadow {
                    alpha: 0.5
                }
            }
        }

        Text {
            text: clockRoot.editMode ? "✔️" : "⚙️"
            font.pixelSize: 24
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            visible: clockRoot.editMode || clockContainer.isHovered

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    clockRoot.editMode = !clockRoot.editMode;
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            property point clickPos
            hoverEnabled: true

            onPressed: mouse => {
                if (clockRoot.editMode) {
                    clickPos = Qt.point(mouse.x, mouse.y);
                    mouse.accepted = true;
                }
            }

            onPositionChanged: mouse => {
                if (clockRoot.editMode && mouseArea.pressed) {
                    var globalPoint = mouseArea.mapToItem(null, mouse.x, mouse.y);
                    clockContainer.x = globalPoint.x - clickPos.x;
                    clockContainer.y = globalPoint.y - clickPos.y;
                }
            }

            onDoubleClicked: {
                clockRoot.editMode = !clockRoot.editMode;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: {
            if (clockRoot.editMode) {
                clockRoot.editMode = false;
            }
            mouse.accepted = false;
        }
    }
}

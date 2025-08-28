import QtQuick
import Quickshell
import QtQuick.Effects

Item {
    id: root

    property bool editMode: false
    property point clockPosition: Qt.point(100, 100)
    property size clockSize: Qt.size(700, 501)
    property color clockColor: "white"
    property string clockFont: "sans-serif"
    property string clockFormat: "hh:mm AP"
    property string clockLocale: "en_US"
    property bool shadowEnabled: false
    property color shadowColor: "#40000000"

    signal positionChanged(point newPosition)
    signal sizeChanged(size newSize)
    signal editModeToggled(bool isEditing, point newPosition, size newSize)

    x: clockPosition.x
    y: clockPosition.y
    width: clockSize.width
    height: clockSize.height

    transformOrigin: Item.Center

    SequentialAnimation {
        id: saveFeedbackAnimation
        PropertyAnimation {
            target: root
            property: "rotation"
            to: -1.5
            duration: 80
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: root
            property: "rotation"
            to: 1.5
            duration: 80
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: root
            property: "rotation"
            to: -1.5
            duration: 80
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: root
            property: "rotation"
            to: 0
            duration: 100
            easing.type: Easing.OutElastic
        }
    }

    function playSaveFeedbackAnimation() {
        saveFeedbackAnimation.start();
    }

    Behavior on x {
        enabled: !root.editMode
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }
    Behavior on y {
        enabled: !root.editMode
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }

    Behavior on width {
        enabled: !root.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on height {
        enabled: !root.editMode
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
        visible: root.editMode
    }

    Text {
        id: timeText
        anchors.fill: parent
        anchors.margins: 20
        text: systemClock.date.toLocaleString(Qt.locale(root.clockLocale), root.clockFormat)
        color: root.clockColor
        font.family: root.clockFont
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        smooth: true
        font.pointSize: 500
        layer.enabled: root.shadowEnabled
        layer.effect: MultiEffect {
            source: timeText
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

        Behavior on font.pointSize {
            NumberAnimation {
                duration: 600
                easing.type: Easing.InOutCubic
            }
        }
    }

    Text {
        text: "⚙️"
        font.pixelSize: 25
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 11
        visible: root.editMode || dragArea.hovered || resizeHandle.isHovered
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.editMode = !root.editMode;
                root.editModeToggled(root.editMode, root.clockPosition, root.clockSize);
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        property point startDragPos
        property point startComponentPos
        onPressed: mouse => {
            if (root.editMode) {
                startComponentPos = Qt.point(root.x, root.y);
                startDragPos = dragArea.mapToItem(null, mouse.x, mouse.y);
                mouse.accepted = true;
            }
        }
        onPositionChanged: mouse => {
            if (pressed && root.editMode) {
                var currentDragPos = dragArea.mapToItem(null, mouse.x, mouse.y);
                var delta = Qt.point(currentDragPos.x - startDragPos.x, currentDragPos.y - startDragPos.y);
                root.x = startComponentPos.x + delta.x;
                root.y = startComponentPos.y + delta.y;
            }
        }
        onReleased: {
            if (root.editMode) {
                root.positionChanged(Qt.point(root.x, root.y));
            }
        }
        onDoubleClicked: {
            root.editMode = !root.editMode;

            const clockPosition = Qt.point(root.x, root.y);
            const clockSize = Qt.size(root.width, root.height);
            root.editModeToggled(root.editMode, clockPosition, clockSize);
        }
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
        visible: root.editMode
        MouseArea {
            id: resizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            property point startMousePos
            property size startComponentSize
            onPressed: {
                startMousePos = mapToItem(null, mouseX, mouseY);
                startComponentSize = Qt.size(root.width, root.height);
            }
            onPositionChanged: {
                if (pressed) {
                    var currentPos = mapToItem(null, mouseX, mouseY);
                    var delta = Qt.point(currentPos.x - startMousePos.x, currentPos.y - startMousePos.y);
                    var newWidth = Math.max(200, startComponentSize.width + delta.x);
                    var newHeight = Math.max(150, startComponentSize.height + delta.y);
                    root.width = newWidth;
                    root.height = newHeight;
                }
            }
            onReleased: {
                root.sizeChanged(Qt.size(root.width, root.height));
            }
        }
    }
}

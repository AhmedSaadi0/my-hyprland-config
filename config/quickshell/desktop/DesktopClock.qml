// File: DesktopClock.qml
import QtQuick
// import QtQuick.Controls
import Quickshell
// import org.kde.kirigami as Kirigami
import QtQuick.Effects

Item {
    id: root

    property point position: Qt.point(0, 0)
    property size size: Qt.size(400, 200)
    property bool editMode: false
    property bool pressed: false
    property bool enableAnimation: false
    property bool shadowEnabled: false
    property color shadowColor: "#40000000"

    property color clockColor: "white"
    property string clockFont: "sans-serif"
    property string clockFormat: "hh:mm"
    property string clockLocale: "en_US"

    signal requestNewGeometry(point newPosition, size newSize)
    signal themeChanged

    x: position.x
    y: position.y
    width: size.width
    height: size.height

    onWidthChanged: resizeDebounceTimer.restart()
    onHeightChanged: resizeDebounceTimer.restart()

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

    SystemClock {
        id: systemClock
    }

    Text {
        id: timeText
        anchors.fill: parent
        text: systemClock.date.toLocaleString(Qt.locale(root.clockLocale), root.clockFormat)

        color: root.clockColor
        font.family: root.clockFont

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 500
        fontSizeMode: Text.Fit

        layer.enabled: root.shadowEnabled && !root.pressed
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }
    }

    Timer {
        id: resizeDebounceTimer
        interval: 250
        repeat: false
        onTriggered: {
            console.log("Debounced resize finished. Forcing text re-layout.");
            timeText.visible = false;
            timeText.visible = true;
        }
    }

    Rectangle {
        visible: root.editMode
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        border.width: 2
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        property point startDragPos
        property point startComponentPos

        onDoubleClicked: {
            console.log("Double-click detected! Toggling edit mode.");
            root.editMode = !root.editMode;
        }

        onPressed: mouse => {
            if (!root.editMode) {
                mouse.accepted = true;
                return;
            }

            startComponentPos = Qt.point(root.x, root.y);
            startDragPos = mapToItem(null, mouse.x, mouse.y);
            mouse.accepted = true;
        }

        onPositionChanged: mouse => {
            if (pressed && root.editMode) {
                var currentDragPos = mapToItem(null, mouse.x, mouse.y);
                var deltaX = currentDragPos.x - startDragPos.x;
                var deltaY = currentDragPos.y - startDragPos.y;
                var newPos = Qt.point(startComponentPos.x + deltaX, startComponentPos.y + deltaY);
                root.requestNewGeometry(newPos, root.size);
            }
        }
    }

    Rectangle {
        id: resizeHandle
        visible: root.editMode
        width: 20
        height: 20
        color: "white"
        radius: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -10

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor

            property point startMousePos
            property size startComponentSize

            onPressed: {
                startMousePos = mapToItem(null, mouseX, mouseY);
                startComponentSize = Qt.size(root.width, root.height);
                root.pressed = true;
            }

            onReleased: {
                root.pressed = false;
                // [تغيير 4]: لم نعد بحاجة لإعادة الإنشاء هنا
            }

            onPositionChanged: {
                if (pressed) {
                    var currentPos = mapToItem(null, mouseX, mouseY);
                    var deltaX = currentPos.x - startMousePos.x;
                    var deltaY = currentPos.y - startMousePos.y;
                    var newSize = Qt.size(Math.max(100, startComponentSize.width + deltaX), Math.max(50, startComponentSize.height + deltaY));
                    root.requestNewGeometry(root.position, newSize);
                }
            }
        }
    }
}

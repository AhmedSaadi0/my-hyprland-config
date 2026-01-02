import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Slider {
    id: control

    property color activeColor: "white"
    property color inactiveColor: "#555555"
    property real lineWidth: 4
    property real scrollStep: 0.05
    property bool enableChangeOnWheel: true

    from: 0.0
    to: 1.0

    handle: Item {
        width: 0
        height: 0
    }

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: control.lineWidth
        width: control.availableWidth
        height: implicitHeight
        radius: height / 2
        color: control.inactiveColor

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.activeColor
            radius: height / 2
        }
    }

    MouseArea {
        acceptedButtons: Qt.NoButton
        anchors.fill: parent
        enabled: control.enableChangeOnWheel
        onWheel: event => {
            if (event.angleDelta.y > 0) {
                control.value = Math.min(control.to, control.value + control.scrollStep);
            } else {
                control.value = Math.max(control.from, control.value - control.scrollStep);
            }
        }
    }
}

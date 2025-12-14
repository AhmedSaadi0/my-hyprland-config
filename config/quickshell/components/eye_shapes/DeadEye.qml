import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property color color: "white"
    property int eyeW: 8
    property int eyeH: 14
    property bool active: false

    anchors.centerIn: parent
    width: eyeW
    height: eyeH

    opacity: active ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    Shape {
        width: 100
        height: 100
        anchors.centerIn: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.samples: 4

        transform: Scale {
            xScale: root.eyeW / 100
            yScale: root.eyeH / 100
            origin.x: 50
            origin.y: 50
        }

        ShapePath {
            strokeWidth: 15
            strokeColor: root.color
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg {
                path: "M 20 20 L 80 80 M 80 20 L 20 80"
            }
        }
    }
}

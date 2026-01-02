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

    property real pulseScale: 1.0
    property color currentHeartColor: root.color

    SequentialAnimation {
        running: root.active
        loops: Animation.Infinite
        alwaysRunToEnd: false

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "pulseScale"
                to: 1.2
                duration: 150
                easing.type: Easing.OutQuad
            }
            ColorAnimation {
                target: root
                property: "currentHeartColor"
                to: "#FF2A68"
                duration: 150
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "pulseScale"
                to: 1.0
                duration: 150
                easing.type: Easing.InQuad
            }
            ColorAnimation {
                target: root
                property: "currentHeartColor"
                to: root.color
                duration: 150
            }
        }
        PauseAnimation {
            duration: 100
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "pulseScale"
                to: 1.1
                duration: 150
                easing.type: Easing.OutQuad
            }
            ColorAnimation {
                target: root
                property: "currentHeartColor"
                to: "#FF2A68"
                duration: 150
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "pulseScale"
                to: 1.0
                duration: 150
                easing.type: Easing.InQuad
            }
            ColorAnimation {
                target: root
                property: "currentHeartColor"
                to: root.color
                duration: 150
            }
        }
        PauseAnimation {
            duration: 600
        }

        onRunningChanged: {
            if (!running) {
                root.pulseScale = 1.0;
                root.currentHeartColor = root.color;
            }
        }
    }

    Shape {
        width: 24
        height: 24
        anchors.centerIn: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.samples: 8
        layer.smooth: true

        transform: Scale {
            xScale: (root.eyeW / 24) * root.pulseScale
            yScale: (root.eyeH / 24) * root.pulseScale
            origin.x: 12
            origin.y: 12
        }

        ShapePath {
            strokeWidth: 0
            fillColor: root.currentHeartColor
            PathSvg {
                path: "M12,21.35 L10.55,20.03 C5.4,15.36 2,12.27 2,8.5 C2,5.41 4.42,3 7.5,3 C9.24,3 10.91,3.81 12,5.08 C13.09,3.81 14.76,3 16.5,3 C19.58,3 22,5.41 22,8.5 C22,12.27 18.6,15.36 13.45,20.03 L12,21.35 Z"
            }
        }
    }
}

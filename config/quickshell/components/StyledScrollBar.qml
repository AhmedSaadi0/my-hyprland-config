import QtQuick
import QtQuick.Controls

ScrollBar {
    id: root

    contentItem: StyledRect {
        implicitWidth: 6
        opacity: root.pressed ? 1 : root.policy === ScrollBar.AlwaysOn || (root.active && root.size < 1) ? 0.8 : 0
        radius: 15
        // color: palette.m3secondary

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                // easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        onWheel: event => {
            if (event.angleDelta.y > 0)
                root.decrease();
            else if (event.angleDelta.y < 0)
                root.increase();
        }
    }
}

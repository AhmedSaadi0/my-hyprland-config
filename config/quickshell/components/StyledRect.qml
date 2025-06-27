import QtQuick

Rectangle {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 300
            easing.type: Easing.BezierSpline
            // easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}

import QtQuick

Transition {
    ParallelAnimation {
        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.8
            duration: 300
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
}

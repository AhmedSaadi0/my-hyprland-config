import QtQuick

Transition {

    property var stackView

    ParallelAnimation {
        NumberAnimation {
            property: "x"
            from: stackView.previousIndex < stackView.currentIndex ? stackView.width : -stackView.width
            to: 0
            duration: 450
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 450
            easing.type: Easing.InOutQuad
        }
    }
}

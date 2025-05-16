import QtQuick 2.15

Item {
    // Push animations
    property Component pushEnter: Component {
        Transition {
            PropertyAnimation {
                property: "x"
                from: target.parent.width
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    property Component pushExit: Component {
        Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: -target.parent.width
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    // Pop animations
    property Component popEnter: Component {
        Transition {
            PropertyAnimation {
                property: "x"
                from: -target.parent.width
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    property Component popExit: Component {
        Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: target.parent.width
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}

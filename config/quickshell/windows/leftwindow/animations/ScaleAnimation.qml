import QtQuick 2.15

Item {
    // Push animations
    property Component pushEnter: Component {
        Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "scale"
                    from: 0.7
                    to: 1.0
                    duration: 300
                    easing.type: Easing.OutBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 200
                }
            }
        }
    }

    property Component pushExit: Component {
        Transition {
            PropertyAnimation {
                property: "scale"
                from: 1.0
                to: 1.1
                duration: 200
                easing.type: Easing.InBack
            }
        }
    }

    // Pop animations
    property Component popEnter: Component {
        Transition {
            PropertyAnimation {
                property: "scale"
                from: 1.1
                to: 1.0
                duration: 200
                easing.type: Easing.OutBack
            }
        }
    }

    property Component popExit: Component {
        Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "scale"
                    from: 1.0
                    to: 0.7
                    duration: 300
                    easing.type: Easing.InBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 200
                }
            }
        }
    }
}

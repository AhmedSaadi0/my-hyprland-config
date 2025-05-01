import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    PersistentProperties {
        id: persist
        reloadableId: "persistedStates"

        property color textBackgroundColor1: "#F905FF"
        property color textBackgroundColor2: "#20D2FD"
        property color textFg: "#09070f"
    }

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        height: 30

        // Background rectangle using system palette color
        Rectangle {
            anchors.fill: parent
            color: palette.window
            z: -1
        }

        Rectangle {
            id: clockBackground
            anchors.centerIn: parent
            // z: -1
            radius: 15
            width: 190
            height: 22

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: persist.textBackgroundColor1
                }   // Start color (left)
                GradientStop {
                    position: 1.0
                    color: persist.textBackgroundColor2
                }   // End color (right)
            }

            Text {
                id: clock
                anchors.centerIn: parent
                color: persist.textFg

                Process {
                    command: ["date", "+(%I:%M) %A, %d %B"]
                    running: true
                    stdout: SplitParser {
                        onRead: data => clock.text = data
                    }
                }
            }
        }
    }
}

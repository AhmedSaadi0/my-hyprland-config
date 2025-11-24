import QtQuick
import QtQuick.Layouts
import "root:/themes"

Row {
    id: root

    property bool playing: false

    spacing: 2
    height: 16
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: 4
        Rectangle {
            id: bar
            width: 3

            height: 4
            radius: 1.5
            color: root.playing ? "#000000" : ThemeManager.selectedTheme.colors.onPrimary
            anchors.bottom: parent.bottom

            SequentialAnimation {
                running: root.playing
                loops: Animation.Infinite

                NumberAnimation {
                    target: bar
                    property: "height"

                    to: 4 + Math.random() * 10

                    duration: 200 + Math.random() * 200
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: bar
                    property: "height"
                    to: 4
                    duration: 200 + Math.random() * 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}

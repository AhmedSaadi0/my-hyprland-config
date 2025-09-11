import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.kirigami as Kirigami

ApplicationWindow {
    id: root
    width: 1920
    height: 1080
    title: "NibrasShell"
    visibility: "FullScreen"

    color: Kirigami.Theme.backgroundColor
    flags: Qt.Window | Qt.FramelessWindowHint

    Item {
        id: splashScreen
        anchors.fill: parent

        Behavior on opacity {
            OpacityAnimator {
                duration: 300
            }
        }

        Text {
            anchors.centerIn: parent
            text: "Loading NibrasShell..."
            color: Kirigami.Theme.textColor
            font.pixelSize: 24
        }
    }
}

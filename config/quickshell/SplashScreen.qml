import QtQuick
import Quickshell
import QtQuick.Window
// import QtQuick.Controls
import org.kde.kirigami as Kirigami
import Quickshell.Wayland

// ApplicationWindow {
PanelWindow {
    id: root
    // width: 1920
    // height: 1080
    // title: "NibrasShell"
    // visibility: "FullScreen"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "NibrasShell:notificationPopup"
    WlrLayershell.layer: WlrLayer.Overlay

    color: Kirigami.Theme.backgroundColor
    // flags: Qt.Window | Qt.FramelessWindowHint

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

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

// windows/leftwindow/monitoring/Main.qml
import QtQuick

Rectangle {
    id: monotoringMenu
    objectName: "monitoring"
    // width: parent.width
    // height: parent.height

    Progresses {
        id: progresses
        width: parent.width
        height: 100
        anchors {
            // verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        // anchors.fill: parent
    }
}

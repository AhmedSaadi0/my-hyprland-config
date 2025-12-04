import QtQuick
import "root:/themes"

Item {
    id: root

    property bool playing: false
    property color barColor: "white"

    // حساب العرض تلقائياً
    implicitWidth: layout.implicitWidth
    implicitHeight: 16

    // 2. المحتوى (البارات)
    Row {
        id: layout
        spacing: 3
        height: parent.height

        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: 4
            Rectangle {
                id: bar
                width: 3
                radius: 1.5
                color: root.barColor
                anchors.bottom: parent.bottom

                property real targetHeight: 4
                height: targetHeight

                Behavior on height {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }

                Timer {
                    running: root.playing
                    repeat: true
                    interval: 100 + Math.random() * 150
                    triggeredOnStart: true
                    onTriggered: {
                        bar.targetHeight = 4 + Math.random() * 12;
                        interval = 100 + Math.random() * 150;
                    }
                    onRunningChanged: if (!running)
                        bar.targetHeight = 4
                }
            }
        }
    }
}

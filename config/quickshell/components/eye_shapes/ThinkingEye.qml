import QtQuick

Item {
    id: root
    property color color: "white"
    property int eyeW: 8 // الحجم الكلي
    property bool active: false

    anchors.centerIn: parent
    width: eyeW
    height: width

    opacity: active ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    // نستخدم Row لترتيب النقاط
    Row {
        anchors.centerIn: parent
        spacing: 3 // مسافة بين النقاط

        Repeater {
            model: 3
            Rectangle {
                width: (root.width - 6) / 3
                height: width
                radius: width / 2
                color: root.color

                // حركة القفز المتتابع
                transform: Translate {
                    y: 0
                    SequentialAnimation on y {
                        running: root.active
                        loops: Animation.Infinite
                        // تأخير زمني لكل نقطة
                        PauseAnimation {
                            duration: index * 150
                        }
                        NumberAnimation {
                            from: 0
                            to: -4
                            duration: 250
                            easing.type: Easing.OutQuad
                        } // قفزة للأعلى
                        NumberAnimation {
                            from: -4
                            to: 0
                            duration: 250
                            easing.type: Easing.OutBounce
                        } // نزول
                        PauseAnimation {
                            duration: 1500 - (index * 150)
                        } // انتظار طويل
                    }
                }
            }
        }
    }
}

// components/eye_shapes/SleepingEye.qml
import QtQuick

Item {
    id: root
    property color color: "white"
    property int eyeW: 10
    property int eyeH: 2
    property bool active: false

    // نسمح للعناصر بالخروج خارج حدود العين (عشان حرف z يطير فوق)
    clip: false

    anchors.centerIn: parent
    width: eyeW
    height: eyeH

    opacity: active ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    // 1. جسم العين (خط يتنفس)
    Rectangle {
        id: eyeLine
        anchors.centerIn: parent
        width: root.eyeW
        height: root.eyeH
        radius: height / 2
        color: root.color

        // أنيميشن التنفس (تغير بسيط في العرض والشفافية)
        SequentialAnimation {
            running: root.active
            loops: Animation.Infinite

            // زفير (انكماش)
            ParallelAnimation {
                NumberAnimation {
                    target: eyeLine
                    property: "width"
                    to: root.eyeW
                    duration: 2000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: eyeLine
                    property: "opacity"
                    to: 0.8
                    duration: 2000
                }
            }
            // شهيق (توسع)
            ParallelAnimation {
                NumberAnimation {
                    target: eyeLine
                    property: "width"
                    to: root.eyeW * 1.2
                    duration: 2000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: eyeLine
                    property: "opacity"
                    to: 1.0
                    duration: 2000
                }
            }
        }
    }

    // 2. حرف Z الطائر
    Timer {
        interval: 1500
        running: root.active
        repeat: true
        triggeredOnStart: false 
        onTriggered: {
            zAnim.restart();
        }
    }

    Text {
        id: zText
        text: "z"
        color: root.color
        font.bold: true
        font.pixelSize: 12
        opacity: 0

        // يبدأ من منتصف العين
        anchors.centerIn: parent

        SequentialAnimation {
            id: zAnim
            running: false

            // تهيئة الموقع
            ScriptAction {
                script: {
                    zText.anchors.horizontalCenterOffset = 0;
                    zText.anchors.verticalCenterOffset = 0;
                }
            }

            ParallelAnimation {
                // ظهور واختفاء
                SequentialAnimation {
                    NumberAnimation {
                        target: zText
                        property: "opacity"
                        to: 1
                        duration: 300
                    }
                    PauseAnimation {
                        duration: 1000
                    }
                    NumberAnimation {
                        target: zText
                        property: "opacity"
                        to: 0
                        duration: 500
                    }
                }

                // حركة للأعلى واليمين
                NumberAnimation {
                    target: zText
                    property: "anchors.verticalCenterOffset"
                    to: -30 // يطير للأعلى
                    duration: 1800
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: zText
                    property: "anchors.horizontalCenterOffset"
                    to: 15 // يميل لليمين
                    duration: 1800
                }
            }
        }
    }
}

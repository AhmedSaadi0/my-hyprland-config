// windows/smart_capsule/ui/components/AIEyePart.qml

import QtQuick
import QtQuick.Shapes // ضروري للرسم

import "root:/components/eye_shapes"

Item {
    id: root

    // --- الخصائص العامة ---
    property color color: "white"
    property int animDur: 300

    // خصائص العين (الأبعاد)
    property int eyeW: 8
    property int eyeH: 14
    property int eyeR: 4

    // خصائص الحاجب
    property int browH: 2
    property int browW: 12
    property int browY: -3
    property int browAngle: 0
    property bool showBrow: true

    // --- حالات الأشكال ---
    property bool isHappyShape: false
    property bool isHeartShape: false
    property bool isSadShape: false
    property bool isThinkingShape: false
    property bool isDeadShape: false
    property bool isListeningShape: false
    property bool isFocusedShape: false
    property bool isSleepingShape: false
    property bool isLeftEye: false

    // أبعاد المكون الرئيسي
    height: 24
    width: Math.max(eyeW, browW)
    anchors.verticalCenter: parent.verticalCenter

    // 1. الحاجب
    Brow {
        id: brow
        color: root.color
        width: root.browW
        height: root.browH
        angle: root.browAngle
        yOffset: root.browY
        animDur: root.animDur
        visible: root.showBrow

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: eyeContainer.top
        anchors.bottomMargin: -root.browY

        // أنيميشن للموقع العمودي عند تغييره
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: root.animDur
                easing.type: Easing.OutBack
            }
        }
    }

    // 2. حاوية العين
    Item {
        id: eyeContainer
        width: root.eyeW
        height: root.eyeH
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        // أنيميشن للأبعاد عند تغيير الحالة
        Behavior on width {
            NumberAnimation {
                duration: root.animDur
                easing.type: Easing.OutBack
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: root.animDur
                easing.type: Easing.OutBack
            }
        }

        // --- المكونات الفرعية ---

        NormalEye {
            color: root.color
            eyeR: root.eyeR
            animDur: root.animDur
            // تكون نشطة فقط إذا لم تكن أي حالة خاصة أخرى مفعلة
            active: !(root.isHappyShape || root.isHeartShape || root.isSadShape || root.isThinkingShape || root.isDeadShape || root.isListeningShape || root.isFocusedShape || root.isSleepingShape)
        }

        HappyEye {
            color: root.color
            eyeW: root.eyeW
            // تظهر إذا كنا سعداء ولسنا في حالة حب (لأن القلب يطغى)
            active: root.isHappyShape && !root.isHeartShape
        }

        SadEye {
            color: root.color
            eyeW: root.eyeW
            active: root.isSadShape
        }

        HeartEye {
            color: root.color
            eyeW: root.eyeW
            eyeH: root.eyeH
            active: root.isHeartShape
        }

        ThinkingEye {
            color: root.color
            eyeW: root.eyeW
            active: root.isThinkingShape
        }

        DeadEye {
            color: root.color
            eyeW: root.eyeW
            eyeH: root.eyeH
            active: root.isDeadShape
        }

        ListeningEye {
            color: root.color
            eyeW: root.eyeW
            active: root.isListeningShape
            // mirrored: root.isLeftEye
        }

        FocusedEye {
            color: root.color
            eyeW: root.eyeW
            eyeH: root.eyeH
            active: root.isFocusedShape
        }

        SleepingEye {
            color: root.color
            eyeW: root.eyeW
            eyeH: root.eyeH
            active: root.isSleepingShape
        }
    }
}

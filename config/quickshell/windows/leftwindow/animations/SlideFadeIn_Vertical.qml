// animations/SlideFadeIn_Vertical.qml
import QtQuick

Transition {

    SequentialAnimation {
        PropertyAction {
            property: "opacity"
            value: 0
        }

        ParallelAnimation {
            NumberAnimation {
                property: "y"
                from: parent.height
                to: 0
                duration: 350
                easing.type: Easing.OutCubic
            }
            // اجعل العنصر يظهر تدريجيًا
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300 // أقصر قليلاً لإنهاء التلاشي قبل نهاية الحركة
                easing.type: Easing.OutQuad
            }
        }
    }
}

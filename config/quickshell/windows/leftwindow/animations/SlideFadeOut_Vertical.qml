// animations/SlideFadeOut_Vertical.qml
import QtQuick

Transition {

    ParallelAnimation {
        // حرك العنصر من مكانه إلى أعلى الشاشة
        NumberAnimation {
            property: "y"
            from: 0
            to: -parent.height / 3 // تحريكه لجزء من الشاشة فقط يجعله أسرع وأكثر سلاسة
            duration: 350
            easing.type: Easing.InCubic
        }
        // اجعل العنصر يختفي تدريجيًا
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 350
            easing.type: Easing.InQuad
        }
    }
}

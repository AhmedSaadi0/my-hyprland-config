// animations/SlideFadeOut_Vertical_ToBottom.qml
import QtQuick

Transition {
    // هذا الأنيميشن مخصص للعنصر الذي يخرج من العرض

    ParallelAnimation {
        // 1. حرك العنصر من مكانه الحالي (y=0) إلى أسفل الشاشة
        NumberAnimation {
            property: "y"
            from: 0
            to: parent.height
            duration: 350
            // استخدم Easing مناسب للخروج (يبدأ بطيئًا ويتسارع)
            easing.type: Easing.InCubic
        }
        // 2. اجعل العنصر يختفي تدريجيًا أثناء حركته
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 350
            easing.type: Easing.InQuad
        }
    }
}

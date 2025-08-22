// animations/SlideOverIn_Horizontal.qml
import QtQuick

Transition {
    ParallelAnimation {
        // حرك الصفحة الجديدة من اليمين إلى مكانها
        NumberAnimation {
            property: "x"
            from: parent.width
            to: 0
            duration: 400
            easing.type: Easing.OutQuint // Easing حاد يعطي شعورًا بالسرعة ثم التباطؤ
        }
        // اجعلها تظهر أثناء الانزلاق
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 250
            easing.type: Easing.OutQuad
        }
    }
}

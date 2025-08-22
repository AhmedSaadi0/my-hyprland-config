// animations/SlideOverOut_Horizontal.qml
import QtQuick

Transition {

    ParallelAnimation {
        // حرك الصفحة القديمة قليلاً إلى اليسار (لإعطاء تأثير العمق)
        NumberAnimation {
            property: "x"
            from: 0
            to: -parent.width / 4
            duration: 400
            easing.type: Easing.OutQuint
        }
        // اجعلها تختفي
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 400
            easing.type: Easing.OutQuad
        }
    }
}

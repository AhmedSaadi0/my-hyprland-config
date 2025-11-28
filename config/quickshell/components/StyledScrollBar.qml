// components/CustomScrollBar.qml

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

ScrollBar {
    id: root

    contentItem: Rectangle {
        implicitWidth: 6

        // نفس منطق الشفافية الذكي
        opacity: root.pressed ? 1 : root.policy === ScrollBar.AlwaysOn || (root.active && root.size < 1) ? 0.8 : 0

        radius: 3 // نصف العرض لمظهر دائري مثالي
        color: Kirigami.Theme.textColor

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }

    // هذا الجزء اختياري لكن يمكن إبقاؤه
    MouseArea {
        z: -1
        anchors.fill: parent
        onWheel: event => {
            if (event.angleDelta.y > 0)
                root.decrease();
            else if (event.angleDelta.y < 0)
                root.increase();
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// --- المكون المساعد: ButtonSegment ---
// هذا مكون مخصص يمثل كل جزء من الزر المقسّم لتحقيق التناسق وتجنب تكرار الكود

Component {
    id: buttonSegment

    Rectangle {
        property alias text: label.text
        property bool isIcon: false
        property int fontSize: isIcon ? buttonIconSize : buttonTextSize
        signal clicked

        // العرض يعتمد على المحتوى + هوامش أفقية
        implicitWidth: label.implicitWidth + 24
        height: parent.height

        // لون الخلفية يتغير عند مرور الفأرة
        color: mouseArea.containsMouse ? buttonHoverColor : "transparent"

        Text {
            id: label
            anchors.centerIn: parent
            color: textColor
            font.pixelSize: parent.fontSize
            // إذا كان المحتوى أيقونة، قد نحتاج لتحديد خط الأيقونات
            font.family: parent.isIcon ? "Font Awesome 5 Free" : "Your Regular Font"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}

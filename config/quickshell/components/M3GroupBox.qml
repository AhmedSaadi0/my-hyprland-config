// components/M3GroupBox.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "../themes"

GroupBox {
    id: root

    // ============================
    // 1. API - الخصائص الخارجية
    // ============================
    default property alias content: userContentColumn.data
    // property int cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int cornerRadius: 8

    // ===================================
    // 2. Styling - المظهر والتصميم
    // ===================================

    // تعديل الهوامش:
    // نجعل الهامش العلوي أصغر لأننا سنتحكم فيه داخليًا
    // ونبقي على الهوامش الجانبية والسفلية
    padding: 0 // نزيل الهامش الافتراضي بالكامل لنتحكم فيه 100%
    topPadding: 12
    leftPadding: 16
    rightPadding: 16
    bottomPadding: 16

    // خصائص خط العنوان
    font.pixelSize: 14
    font.weight: Font.Medium

    // الخلفية تبقى كما هي
    background: Rectangle {
        radius: root.cornerRadius
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        border.width: 1
    }

    // ================================================
    // 3. Structure - الهيكل الداخلي (هنا التغيير)
    // ================================================

    // نتحكم في محتوى الـ GroupBox بالكامل
    contentItem: Item {
        // نربط الأبعاد الضمنية بالـ ColumnLayout الداخلي
        implicitWidth: mainLayout.implicitWidth
        implicitHeight: mainLayout.implicitHeight

        ColumnLayout {
            id: mainLayout
            // اجعل هذا التخطيط يملأ الـ contentItem
            anchors.fill: parent

            // 1. العنوان (موجود بالفعل، لكننا نضع تحته فاصل)
            // لا نحتاج لإعادة تعريف العنوان هنا، GroupBox يقوم بذلك

            // 2. الفاصل المرئي (لتمييز العنوان)
            Rectangle {
                // اجعله يظهر فقط إذا كان هناك عنوان
                visible: root.title.length > 0

                Layout.fillWidth: true
                Layout.topMargin: 15
                Layout.bottomMargin: 10
                Layout.leftMargin: -root.leftPadding // اجعل الخط يمتد ليلمس الحواف
                Layout.rightMargin: -root.rightPadding
                height: 1
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            }

            // 3. العمود الذي سيحتوي على محتوى المستخدم
            ColumnLayout {
                id: userContentColumn
                Layout.fillWidth: true
                spacing: 12
            }
        }
    }
}

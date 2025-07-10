// Card.qml
import QtQuick
import QtQuick.Controls // Pane is in Controls
import QtQuick.Layouts

import "root:/themes"

// Pane هو المكون الأساسي المثالي لبطاقة مرئية
Pane {
    id: root
    // padding: 15            // الهامش الداخلي للبطاقة

    // --- الخصائص العامة للبطاقة ---
    // يمكنك تغيير هذه القيم عند استخدام البطاقة

    // 1. خصائص المحتوى (التي يتم الوصول إليها من الخارج)
    property alias title: titleElement.text
    property alias icon: iconElement.text

    // 2. خصائص التصميم
    property color cardColor: ThemeManager.selectedTheme.colors.topbarBgColorV1
    property color textColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
    property int cardRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int headerSpacing: 10      // المسافة بين الأيقونة والعنوان

    // 3. خصائص الخطوط
    property int titleFontSize: ThemeManager.selectedTheme.typography.heading3Size
    property int iconFontSize: ThemeManager.selectedTheme.typography.heading3Size
    // ملاحظة: تأكد من أن خط NerdFont مُحمّل في مشروعك
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont

    // اجعل البطاقة تأخذ عرض الأب بشكل افتراضي
    implicitWidth: parent.implicitWidth
    // الارتفاع يُحسب تلقائيًا بناءً على المحتوى
    implicitHeight: mainLayout.implicitHeight

    // هذه هي الميزة الأهم:
    // أي عنصر تضعه داخل <Card> سيذهب إلى contentArea
    default property alias content: contentArea.data

    // تخصيص خلفية الـ Pane
    background: Rectangle {
        color: root.cardColor
        radius: root.cardRadius
    }

    // الهيكل الداخلي للبطاقة باستخدام Layouts
    ColumnLayout {
        id: mainLayout
        width: parent.width // اجعل التخطيط يملأ عرض البطاقة

        // --- الجزء الأول: رأس البطاقة (Header) ---
        RowLayout {
            // اجعل الرأس يأخذ العرض الكامل مع تطبيق الهوامش
            Layout.fillWidth: true
            Layout.margins: root.padding
            // لا نريد هامشًا سفليًا هنا، سنضيف فاصل بدلاً منه
            Layout.bottomMargin: 0
            spacing: root.headerSpacing

            // الأيقونة
            Text {
                id: iconElement
                text: "\uf128"
                font.family: root.iconFontFamily
                font.pixelSize: root.iconFontSize
                color: root.textColor
                Layout.alignment: Qt.AlignCenter
            }

            // العنوان
            Text {
                id: titleElement
                text: qsTr("عنوان البطاقة")
                font.pixelSize: root.titleFontSize
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight // يضيف "..." إذا كان النص طويلاً
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true // اجعل العنوان يملأ باقي المساحة
            }
        }

        // --- فاصل مرئي بين الرأس والمحتوى ---
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: root.padding
            Layout.rightMargin: root.padding
            Layout.topMargin: root.padding / 2
            Layout.bottomMargin: root.padding / 2
            height: 1
            color: root.textColor
        }

        // --- الجزء الثاني: منطقة المحتوى (Content) ---
        // هذه هي الحاوية التي ستستقبل العناصر من الخارج
        ColumnLayout {
            id: contentArea
            Layout.fillWidth: true
            Layout.margins: root.padding
            spacing: 10
            Layout.bottomMargin: 20
        }
    }
}

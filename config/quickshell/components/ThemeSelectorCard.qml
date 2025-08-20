// components/ThemeSelectorCard.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls // <-- هذا هو السطر الذي تم إضافته لإصلاح الخطأ
import org.kde.kirigami as Kirigami

import "root:/themes"

// هذا هو الإطار الخارجي للبطاقة
Rectangle {
    id: card

    // خصائص لتمرير أسماء الثيمات والعنوان
    property string themeTitle: "Theme"
    property string lightThemeName: ""
    property string darkThemeName: ""

    property bool isSelected: false

    // اجعل عرض البطاقة يملأ المساحة المتاحة
    width: parent.width
    // استخدم نصف القطر من الثيم المطبق حاليًا لتوحيد الشكل
    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    // استخدم لون خلفية مناسب من Kirigami
    color: ThemeManager.selectedTheme.colors.topbarBgColorV2.alpha(0.7)
    // ارتفاع تلقائي بناءً على المحتوى
    height: columnLayout.implicitHeight + 20

    border.width: isSelected ? 2 : 0 // عرض الحد 2 بكسل إذا كانت مختارة، وإلا 0
    border.color: isSelected ? ThemeManager.selectedTheme.colors.primary : "transparent" // استخدم اللون الأساسي للثيم

    Behavior on border.width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    // تخطيط عمودي للمحتوى داخل البطاقة
    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        anchors.margins: 10 // هوامش داخلية للبطاقة

        // 1. العنوان الصغير
        Label {
            // <-- الآن سيتعرف عليه المحرك
            text: card.themeTitle
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            Layout.bottomMargin: 4
        }

        // 2. صف يحتوي على زري الفاتح والداكن
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // زر الثيم الفاتح
            MButton {
                text: ""
                // iconText: "" // أيقونة الوضع الفاتح
                Layout.fillWidth: true
                onClicked: ThemeManager.loadTheme(card.lightThemeName)
                // اجعل الزر نشطًا إذا كان هو الثيم المختار حاليًا
                isActive: ThemeManager.selectedTheme.themeName === card.lightThemeName
                topRightRadius: 0
                bottomRightRadius: 0
            }

            // زر الثيم الداكن
            MButton {
                text: "󰖔"
                // iconText: "󰖔" // أيقونة الوضع الداكن
                Layout.fillWidth: true
                onClicked: ThemeManager.loadTheme(card.darkThemeName)
                // اجعل الزر نشطًا إذا كان هو الثيم المختار حاليًا
                isActive: ThemeManager.selectedTheme.themeName === card.darkThemeName

                topLeftRadius: 0
                bottomLeftRadius: 0
            }
        }
    }
}

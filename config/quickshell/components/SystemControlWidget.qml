import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "root:/themes"

Item {
    id: controlWidget

    property string icon: ""
    property real value: 0.0
    property color accentColor: "white"

    // خاصية لنعرف في الخارج هل المستخدم يضغط على الشريط
    property alias pressed: slider.pressed

    signal userChangedValue(real newValue)

    // استخدمنا Item داخلي لضبط الحجم والمحاذاة بدقة
    Item {
        width: parent.width
        height: 40 // ارتفاع المحتوى الفعلي (الأيقونة + الشريط)
        anchors.centerIn: parent // هذا يضمن التوسط العمودي والأفقي 100%

        RowLayout {
            anchors.fill: parent
            spacing: 15

            // الأيقونة
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                // radius: 20
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)

                Text {
                    anchors.centerIn: parent
                    text: controlWidget.icon
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 20
                    color: ThemeManager.selectedTheme.colors.onPrimary
                    // إصلاح بسيط لمحاذاة النص داخل الدائرة بدقة
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // شريط السحب
            Slider {
                id: slider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter // توسيط عمودي داخل الـ Row

                from: 0.0
                to: 1.0

                Binding on value {
                    when: !slider.pressed
                    value: controlWidget.value
                }

                onMoved: controlWidget.userChangedValue(value)

                Material.accent: controlWidget.accentColor
                Material.theme: Material.Dark
            }

            // النسبة
            Text {
                text: Math.round(slider.value * 100) + "%"
                color: ThemeManager.selectedTheme.colors.onPrimary
                font.bold: true
                Layout.preferredWidth: 20
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}

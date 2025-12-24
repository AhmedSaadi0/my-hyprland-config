import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import "root:/themes"

RowLayout {
    id: root

    // --- Inputs ---
    property alias label: titleLabel.text
    property double from: 0
    property double to: 100
    property double value: 0
    property double stepSize: 1.0
    property int decimals: 0 // عدد الخانات العشرية (مثلاً 1 لـ 0.5، 2 لـ 0.25)

    // --- Outputs ---
    // يتم إطلاقه عند السحب (للعرض الفوري)
    signal currentValueChanged(double newValue)
    // يتم إطلاقه عند ترك الماوس (للحفظ)
    signal editingFinished(double finalValue)

    spacing: ThemeManager.selectedTheme.dimensions.spacingMedium

    // 1. عنوان العنصر
    Controls.Label {
        id: titleLabel
        font.bold: true
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

    // 2. شريط السحب
    Controls.Slider {
        id: slider
        Layout.preferredWidth: 200
        Layout.alignment: Qt.AlignVCenter

        from: root.from
        to: root.to
        stepSize: root.stepSize

        // يجعل المؤشر ينجذب للقيم الصحيحة فقط بناءً على stepSize
        snapMode: Controls.Slider.SnapAlways

        // الربط الأولي للقيمة
        value: root.value

        // عند التحريك (تفاعل المستخدم)
        onMoved: {
            // نقوم بتقريب الرقم لتجنب مشاكل الفواصل العائمة (0.3000004)
            var preciseValue = parseFloat(value.toFixed(root.decimals));
            root.currentValueChanged(preciseValue);
        }

        // عند الانتهاء من السحب (إفلات الماوس)
        onPressedChanged: {
            if (!pressed) {
                var finalValue = parseFloat(value.toFixed(root.decimals));
                root.editingFinished(finalValue);
            }
        }

        // تحديث السلايدر إذا تغيرت القيمة من الخارج (مثلاً عند عمل Reset)
        Connections {
            target: root
            function onValueChanged() {
                // نحدث السلايدر فقط إذا لم يكن المستخدم يمسكه حالياً
                if (!slider.pressed && slider.value !== root.value) {
                    slider.value = root.value;
                }
            }
        }
    }

    // 3. عرض القيمة الرقمية
    Controls.Label {
        id: valueLabel

        // التغيير الجوهري هنا: استخدام toFixed مباشرة كسلسلة نصية
        // هذا يضمن ظهور "1.0" بدلاً من "1" إذا كانت decimals = 1
        text: slider.value.toFixed(root.decimals)

        font.bold: true
        color: ThemeManager.selectedTheme.colors.primary

        Layout.minimumWidth: 50
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter

        // خلفية خفيفة لتمييز الرقم (اختياري، لجمالية أكثر)
        background: Rectangle {
            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV1
            radius: 4
            opacity: 0.5
        }

        // هوامش داخلية لكي لا يلتصق النص بالحواف
        leftPadding: 8
        rightPadding: 8
        topPadding: 4
        bottomPadding: 4
    }
}

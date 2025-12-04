// components/monitors/Battery.qml

import QtQuick
import Quickshell.Services.UPower

import "root:/components"
import "root:/themes"

TopbarCircularProgress {
    id: batteryUsage

    activeProcess: false

    // 2. الوصول لبيانات البطارية
    // نستخدم displayDevice عادة لأنه يدمج البطاريات (لو كان لابتوب ببطاريتين)
    // إذا لم يعمل معك displayDevice عد إلى values[0]
    property var battery: UPower.displayDevice ?? UPower.devices.values[0]

    //  دالة التحديث (يتم استدعاؤها تلقائياً عند تغير أي قيمة)
    function updateBatteryInfo() {
        if (!battery)
            return;

        const percentage = battery.percentage;
        const state = battery.state; // 1: Charging, 2: Discharging, 4: Full, etc.
        const isCharging = (state === 1 || state === 4); // 1=Charging, 4=Fully Charged

        // تحديث القيمة في المكون الأصلي
        batteryUsage.value = percentage;

        // منطق الأيقونات (تم تبسيطه باستخدام المصفوفات بدل if-else الطويلة)
        const dischargeIcons = ['󰁺', '󰁻', '󰁼', '󰁽', '󰁾', '󰁿', '󰂀', '󰂁', '󰂂', '󰁹'];
        const chargeIcons = ['󰢜', '󰂆', '󰂇', '󰂈', '󰢝', '󰂉', '󰢞', '󰂊', '󰂋', '󰂅'];

        // معادلة لتحويل النسبة (0.0 - 1.0) إلى فهرس (0 - 9)
        // Math.min(9, ...) لضمان عدم تجاوز المصفوفة عند الوصول لـ 100%
        let index = Math.min(9, Math.floor(percentage * 10));

        // تصحيح بسيط للنسب القليلة جداً لتظهر الأيقونة الأولى
        if (percentage > 0 && index < 0)
            index = 0;

        if (isCharging) {
            batteryUsage.icon = chargeIcons[index];
            batteryUsage.glowIcon = true; // تفعيل التوهج عند الشحن
        } else {
            batteryUsage.icon = dischargeIcons[index];
            batteryUsage.glowIcon = false;
        }
    }

    // 4. مراقبة التغيرات في كائن البطارية وتشغيل الدالة تلقائياً
    Connections {
        target: battery
        function onPercentageChanged() {
            updateBatteryInfo();
        }
        function onStateChanged() {
            updateBatteryInfo();
        }
    }

    // تشغيل التحديث لأول مرة عند اكتمال التحميل
    Component.onCompleted: {
        updateBatteryInfo();
    }
}

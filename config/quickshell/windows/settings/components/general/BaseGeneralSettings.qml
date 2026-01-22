// windows/settings/components/BaseGeneralSettings.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components/base"

M3GroupBox {
    id: root

    // --- إعدادات العنوان الافتراضية ---
    property var selectedTheme: ThemeManager.selectedTheme

    // --- حالة البيانات ---
    property bool isLoading: true
    property bool isReady: false

    // دوال مساعدة لاستدعاء أبعاد وخطوط الثيم بسرعة
    function dim(k, d) {
        return selectedTheme ? selectedTheme.dimensions[k] : d;
    }
    function typ(k, d) {
        return selectedTheme ? selectedTheme.typography[k] : d;
    }

    // --- إشارات (Signals) ---
    signal saveChanges      // تم الحفظ بنجاح
    signal cancelChanges    // تم الضغط على زر إلغاء

    // =========================================================
    // دوال افتراضية (يجب عمل Override لها في الصفحات)
    // =========================================================

    // 1. قراءة البيانات من App (Global) ووضعها في متغيرات محلية (Local Properties)
    function syncFromConfig() {
        console.warn("BaseGeneralSettings: syncFromConfig() needs to be overridden in " + root.title);
    }

    // 2. تحويل المتغيرات المحلية إلى كائن JSON للحفظ
    function serializeData() {
        console.warn("BaseGeneralSettings: serializeData() needs to be overridden in " + root.title);
        return {};
    }

    // =========================================================
    // منطق العمل (Core Logic)
    // =========================================================

    // تحديث الواجهة (إلغاء التغييرات / تحميل أولي)
    function refresh() {
        isLoading = true;
        syncFromConfig(); // هذا السطر هو المهم
        isReady = true;
        isLoading = false;
    }

    // حفظ البيانات
    function applyChanges() {
        if (isLoading || !isReady)
            return;

        // 1. جمع البيانات
        let dataToSave = serializeData();

        // 2. التحقق من وجود بيانات
        if (Object.keys(dataToSave).length === 0) {
            return;
        }

        // 3. الحفظ عبر App (تحديث متعدد)
        // نفترض أن App.updateConfigMultiple هي الدالة المستخدمة للحفظ
        App.updateConfigMultiple(dataToSave);

        root.saveChanges();
    }

    // عند اكتمال التحميل، قم بجلب البيانات
    Component.onCompleted: {
        Qt.callLater(() => {
            refresh();
        });
    }

    // =========================================================
    // الشريط السفلي (Footer)
    // =========================================================
    footer: RowLayout {
        spacing: dim("spacingMedium", 10)

        // زر إعادة تعيين (يعيد تحميل القيم المحفوظة حالياً، أي "تراجع")
        MButton {
            text: "Reset / Undo"
            Layout.preferredWidth: 120
            onClicked: root.refresh()
        }

        Item {
            Layout.fillWidth: true
        }

        MButton {
            text: "Cancel"
            Layout.preferredWidth: 100
            onClicked: {
                root.refresh(); // إعادة تعيين القيم قبل الخروج
                root.cancelChanges();
            }
        }

        MButton {
            text: "Save"
            Layout.preferredWidth: 100
            highlighted: true
            onClicked: root.applyChanges()
        }
    }
}

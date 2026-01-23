// windows/settings/components/BaseThemeSettings.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components/base"

M3GroupBox {
    id: root

    property bool isLoading: true
    property bool isReady: false
    property string lastThemeName: ""

    property bool showApplyButton: false

    readonly property var theme: ThemeManager.selectedTheme

    function dim(k, d) {
        return theme ? theme.dimensions[k] : d;
    }
    function typ(k, d) {
        return theme ? theme.typography[k] : d;
    }

    signal saveChanges
    signal cancelChanges
    signal resetToDefaultClicked

    function syncFromTheme() {
        console.warn("BaseThemeSettings: syncFromTheme() needs to be overridden");
    }

    function serializeData() {
        console.warn("BaseThemeSettings: serializeData() needs to be overridden");
        return {};
    }

    function refresh(force) {
        if (!theme)
            return;

        if (force || theme.themeName !== lastThemeName) {
            isLoading = true;

            syncFromTheme();

            lastThemeName = theme.themeName;
            isReady = true;
            isLoading = false;
            console.info("[" + root.title + "] Local state refreshed.");
        }
    }

    function collectAndApply(saveToDisk) {
        if (isLoading || !isReady || !theme)
            return;

        let data = serializeData();

        ThemeManager.updateAndApplyTheme(data, saveToDisk);

        if (saveToDisk) {
            root.saveChanges();
        }
    }

    function applySingleProperty(key, value, saveToDisk = false) {
        if (isLoading || !isReady || !theme)
            return;

        if (saveToDisk === undefined)
            saveToDisk = false;

        let data = {};
        data[key] = value;

        console.info("[" + root.title + "] Applying single property:", key, value);

        // TODO: -> create a function to apply single property
        ThemeManager.updateAndApplyTheme(data, saveToDisk);

        if (saveToDisk) {
            root.saveChanges();
        }
    }

    function resetToDefault() {
        let data = serializeData();
        ThemeManager.loadDefaultValues(data);
        root.resetToDefaultClicked();
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            refresh(true);
        });
    }

    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
            if (!root.isLoading)
                refresh(true);
        }
    }

    footer: RowLayout {
        spacing: dim("spacingMedium", 10)

        MButton {
            text: "Reset"
            Layout.preferredWidth: 100
            onClicked: root.resetToDefault()
        }

        // زر تنظيف الكاش يظهر فقط إذا تم تعريف الإشارة في الاستخدام
        MButton {
            text: "Clear Cache"
            visible: root.hasOwnProperty("clearUnusedCache")
            Layout.preferredWidth: 120
            onClicked: root.clearUnusedCache()
        }

        Item {
            Layout.fillWidth: true
        }

        MButton {
            text: "Cancel"
            Layout.preferredWidth: 100
            onClicked: {
                root.refresh(true);
                root.cancelChanges();
            }
        }

        // زر تطبيق (بدون حفظ) - يظهر حسب الخاصية
        MButton {
            text: "Apply"
            visible: root.showApplyButton
            Layout.preferredWidth: 100
            onClicked: root.collectAndApply(false)
        }

        MButton {
            text: "Save"
            Layout.preferredWidth: 100
            highlighted: true
            onClicked: root.collectAndApply(true)
        }
    }
}

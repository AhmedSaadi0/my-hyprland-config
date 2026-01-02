import QtQuick
import "root:/themes" as Theme
import "root:/components"

Item {
    id: widgetsRoot
    anchors.fill: parent

    // خاصية للتحكم في شفافية وحجم الويدجت (عند فتح القائمة الجانبية)
    property bool dimWidgets: false

    // ---------------------------------------------------------
    // 1. إعدادات الساعة والمتغيرات
    // ---------------------------------------------------------
    readonly property var clockSettings: Theme.ThemeManager.selectedTheme.desktopClock
    readonly property point themeClockPosition: clockSettings?.enabled ? clockSettings.position : Qt.point(0, 0)
    readonly property size themeClockSize: clockSettings?.enabled ? clockSettings.size : Qt.size(0, 0)

    // متغيرات محلية للتحكم الحي
    property point currentClockPosition: themeClockPosition
    property size currentClockSize: themeClockSize

    // ---------------------------------------------------------
    // 2. تحميل الساعة
    // ---------------------------------------------------------
    Loader {
        id: clockLoader
        z: 1
        active: clockSettings?.enabled || false
        sourceComponent: clockComponent

        transformOrigin: Item.Center

        scale: widgetsRoot.dimWidgets ? 0.85 : 1.0
        opacity: widgetsRoot.dimWidgets ? 0.8 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuart
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuart
            }
        }

        onLoaded: {
            // تحديث القيم عند التحميل
            widgetsRoot.currentClockPosition = widgetsRoot.themeClockPosition;
            widgetsRoot.currentClockSize = widgetsRoot.themeClockSize;
        }
    }

    // ---------------------------------------------------------
    // 3. مكون الساعة وتفاصيله
    // ---------------------------------------------------------
    Component {
        id: clockComponent
        DesktopClock {
            id: theClock
            position: widgetsRoot.currentClockPosition
            size: widgetsRoot.currentClockSize
            editMode: false

            clockColor: widgetsRoot.clockSettings?.useThemeColor ? Theme.ThemeManager.selectedTheme.colors.primary.alpha(0.7) : (widgetsRoot.clockSettings?.color || "white")

            clockFont: widgetsRoot.clockSettings?.font || "Arial"
            clockFormat: widgetsRoot.clockSettings?.format || "hh:mm:ss"
            clockLocale: widgetsRoot.clockSettings?.local || "en_US"

            enableAnimation: widgetsRoot.clockSettings?.enableAnimation || false

            shadowEnabled: widgetsRoot.clockSettings?.shadowEnabled || false
            shadowColor: widgetsRoot.clockSettings?.shadowColor || "black"

            // منطق التحديث (عندما يقوم المستخدم بتحريك الساعة)
            onRequestNewGeometry: (newPosition, newSize) => {
                widgetsRoot.currentClockPosition = newPosition;
                widgetsRoot.currentClockSize = newSize;
            }

            // منطق الحفظ (عند الانتهاء من التعديل)
            onEditModeChanged: {
                if (!editMode) {
                    Theme.ThemeManager.updateAndApplyTheme({
                        "_desktopClockPosition": widgetsRoot.currentClockPosition,
                        "_desktopClockSize": widgetsRoot.currentClockSize
                    }, true);
                }
            }
        }
    }

    // ---------------------------------------------------------
    // 4. منطقة الماوس (للخروج من وضع التعديل)
    // ---------------------------------------------------------
    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: {
            if (clockLoader.item?.editMode) {
                clockLoader.item.editMode = false;
            }
        }
    }

    // مراقبة التحديثات القادمة من الثيم وتطبيقها فوراً
    Connections {
        target: Theme.ThemeManager
        function onSelectedThemeUpdated() {
            if (widgetsRoot.clockSettings?.enabled) {
                let newPos = widgetsRoot.themeClockPosition;
                let newSize = widgetsRoot.themeClockSize;
                // إذا كان الحجم الجديد صالحاً، قم بالتحديث
                if (newSize.width > 0) {
                    widgetsRoot.currentClockPosition = newPos;
                    widgetsRoot.currentClockSize = newSize;
                }
            }
        }
    }
}

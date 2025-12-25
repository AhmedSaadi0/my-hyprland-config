// desktop/Desktop.qml

import QtQuick
import Quickshell
import Quickshell.Wayland

import "root:/themes" as Theme
import "root:/components"
import "root:/config/EventNames.js" as Events
import "root:/config"

PanelWindow {
    id: desktopRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    aboveWindows: false
    focusable: true
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "NibrasShell:wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    property bool isMenuOpened: false
    property string currentOverlay: ""
    property bool depthEffectActive: false

    Wallpaper {
        id: wallpaper
        anchors.fill: parent

        overlaySource: desktopRoot.currentOverlay
        depthEnabled: desktopRoot.depthEffectActive
        isMenuOpen: desktopRoot.isMenuOpened

        content: Widgets {
            id: myWidgets
            dimWidgets: desktopRoot.isMenuOpened
        }
    }

    // ---------------------------------------------------------
    // المنطق: تحديث البيانات والأحداث
    // ---------------------------------------------------------
    function updateThemeData() {
        // 1. الخلفية

        // 2. إعدادات العمق (Overlay)
        let clockSettings = Theme.ThemeManager.selectedTheme.desktopClock;
        let isDepth = (clockSettings?.enabled && clockSettings?.depthEffectEnabled) || false;

        desktopRoot.depthEffectActive = isDepth;
        desktopRoot.currentOverlay = isDepth ? (clockSettings?.depthOverlayPath || "") : "";
    }

    // استقبال إشارات تغيير الثيم
    Connections {
        target: Theme.ThemeManager

        function onSelectedThemeUpdated() {
            desktopRoot.updateThemeData();
        }

        function onWallpaperReady() {
            wallpaper.wallpaperSource = Theme.ThemeManager.currentWallpaper;
        }
    }

    // إدارة أحداث القائمة (Menu)
    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            desktopRoot.isMenuOpened = true;
        });
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            desktopRoot.isMenuOpened = false;
        });

        // التحميل الأولي
        desktopRoot.updateThemeData();
        wallpaper.wallpaperSource = Theme.ThemeManager.currentWallpaper;
    }
}

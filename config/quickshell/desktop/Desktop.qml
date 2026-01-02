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
    property bool blurEnabled: false

    Wallpaper {
        id: wallpaper
        anchors.fill: parent

        overlaySource: desktopRoot.currentOverlay
        depthEnabled: desktopRoot.depthEffectActive
        isMenuOpen: desktopRoot.isMenuOpened
        blurEnabled: desktopRoot.blurEnabled

        content: Widgets {
            id: myWidgets
            dimWidgets: desktopRoot.isMenuOpened
        }
    }

    // ---------------------------------------------------------
    // المنطق: تحديث البيانات والأحداث
    // ---------------------------------------------------------
    function updateThemeData() {
        // 2. إعدادات العمق (Overlay)
        let clockSettings = Theme.ThemeManager.selectedTheme.desktopClock;
        let isDepth = (clockSettings?.enabled && clockSettings?.depthEffectEnabled) || false;

        desktopRoot.depthEffectActive = isDepth;
        desktopRoot.currentOverlay = isDepth ? (clockSettings?.depthOverlayPath || "") : "";
        desktopRoot.blurEnabled = Theme.ThemeManager.selectedTheme.systemSettings.enableWallpaperBlur;
    }

    // استقبال إشارات تغيير الثيم
    Connections {
        target: Theme.ThemeManager

        function onSelectedThemeUpdated() {
            desktopRoot.updateThemeData();
        }

        function onWallpaperChanged(path) {
            wallpaper.wallpaperSource = path;
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

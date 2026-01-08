// desktop/Desktop.qml

import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland

import "root:/components"
import "root:/config"
import "root:/themes" as Theme
import "root:/config/EventNames.js" as Events
import "root:/config/ConstValues.js" as C

PanelWindow {
    id: desktopRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: Theme.ThemeManager.selectedTheme.colors.topbarColor

    aboveWindows: false
    focusable: true
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "NibrasShell:wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    property bool isMenuOpened: false
    property string currentOverlay: ""
    property bool depthEffectActive: false
    property bool blurEnabled: false

    property int elementRadius: Theme.ThemeManager.selectedTheme.dimensions.elementRadius
    property int cornerRadius: elementRadius <= 1 ? 0 : elementRadius + 6

    // ---------------------------------------------------------
    // حاوية الورقة العائمة (تجمع الظل والمحتوى)
    // ---------------------------------------------------------
    Item {
        id: sheetContainer
        anchors.fill: parent

        // الهوامش التي تصنع شكل البارات
        anchors.topMargin: Theme.ThemeManager.selectedTheme.dimensions.barHeight + 3
        anchors.leftMargin: Theme.ThemeManager.selectedTheme.dimensions.leftBarWidth + 2
        anchors.rightMargin: 5
        anchors.bottomMargin: 5

        // -----------------------------------------------------
        // الإضافة الجديدة: تحريك الحاوية بالكامل لليمين
        // -----------------------------------------------------
        transform: Translate {
            // التحرك 400 بكسل لليمين عند فتح القائمة، وصفر عند إغلاقها
            x: App.menuStyle !== C.FLOATING && desktopRoot.isMenuOpened ? Theme.ThemeManager.selectedTheme.dimensions.menuWidth + 5 : 0

            // جعل الحركة ناعمة
            Behavior on x {
                NumberAnimation {
                    duration: 600
                    easing.type: desktopRoot.isMenuOpened ? Easing.OutCubic : Easing.OutExpo
                }
            }
        }

        // 1. طبقة الظل الخلفية
        Rectangle {
            id: shadowRect
            anchors.fill: parent
            radius: desktopRoot.cornerRadius
            color: Theme.ThemeManager.selectedTheme.colors.topbarColor

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.5)
                shadowBlur: 1.0
                shadowVerticalOffset: -1
                shadowHorizontalOffset: -1
                shadowScale: 1.0
            }
        }

        // 2. طبقة الخلفية والصور
        Wallpaper {
            id: wallpaper
            anchors.fill: parent

            overlaySource: desktopRoot.currentOverlay
            depthEnabled: desktopRoot.depthEffectActive
            isMenuOpen: desktopRoot.isMenuOpened
            blurEnabled: desktopRoot.blurEnabled
            blurValue: Theme.ThemeManager.selectedTheme.systemSettings.wallpaperBlurStrength

            content: Widgets {
                id: myWidgets
                dimWidgets: desktopRoot.isMenuOpened
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: maskItem
            }
        }

        // 3. عنصر القناع
        Item {
            id: maskItem
            anchors.fill: parent
            visible: false

            Rectangle {
                anchors.fill: parent
                radius: desktopRoot.cornerRadius
                color: "black"
            }
        }
    }

    // ---------------------------------------------------------
    // المنطق
    // ---------------------------------------------------------
    function updateThemeData() {
        let clockSettings = Theme.ThemeManager.selectedTheme.desktopClock;
        let isDepth = (clockSettings?.enabled && clockSettings?.depthEffectEnabled) || false;

        desktopRoot.depthEffectActive = isDepth;
        desktopRoot.currentOverlay = isDepth ? (clockSettings?.depthOverlayPath || "") : "";
        desktopRoot.blurEnabled = Theme.ThemeManager.selectedTheme.systemSettings.enableWallpaperBlur;
    }

    Connections {
        target: Theme.ThemeManager
        function onSelectedThemeUpdated() {
            desktopRoot.updateThemeData();
        }
        function onWallpaperChanged(path) {
            wallpaper.wallpaperSource = path;
        }
        function onCreatingOverlayImageFinished(newImagePath) {
            desktopRoot.currentOverlay = newImagePath;
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            changeIsMenuOpen.newValue = true;
            changeIsMenuOpen.start();
        });
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            changeIsMenuOpen.newValue = false;
            changeIsMenuOpen.start();
        });

        desktopRoot.updateThemeData();
        wallpaper.wallpaperSource = Theme.ThemeManager.currentWallpaper;
    }

    Timer {
        id: changeIsMenuOpen
        interval: 30
        repeat: false
        property bool newValue: false
        onTriggered: {
            desktopRoot.isMenuOpened = newValue;
            if (App.menuStyle !== C.FLOATING)
                addLeftSpace();
        }
    }

    function addLeftSpace() {
        if (desktopRoot.isMenuOpened) {
            Theme.ThemeManager.addLeftMenuSpacing();
        } else {
            Theme.ThemeManager.resetLeftMenuSpacing();
        }
    }
}

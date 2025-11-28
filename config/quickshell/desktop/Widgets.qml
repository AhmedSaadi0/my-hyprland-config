import QtQuick
import Quickshell

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

    // ---------------------------------------------------------
    // 1. إعدادات الساعة والمتغيرات
    // ---------------------------------------------------------
    readonly property var clockSettings: Theme.ThemeManager.selectedTheme.desktopClock
    readonly property point themeClockPosition: clockSettings?.enabled ? clockSettings.position : Qt.point(0, 0)
    readonly property size themeClockSize: clockSettings?.enabled ? clockSettings.size : Qt.size(0, 0)

    property point currentClockPosition: themeClockPosition
    property size currentClockSize: themeClockSize

    // ---------------------------------------------------------
    // 2. متغيرات التحكم في الصور
    // ---------------------------------------------------------
    property bool showChannel1: true
    property string targetWallpaper: ""
    property string targetOverlay: ""

    // ---------------------------------------------------------
    // 3. طبقة الخلفية (Background Layer) - تم تطبيق الحل هنا فقط
    // ---------------------------------------------------------
    Item {
        id: backgroundLayer
        z: -1
        anchors.fill: parent

        transformOrigin: Item.Center
        scale: 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuart
            }
        }

        Image {
            id: bg1
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)

            // === منطق منع الفراغ (Overlap) للخلفية فقط ===
            states: [
                State {
                    name: "active"
                    when: desktopRoot.showChannel1
                    PropertyChanges {
                        target: bg1
                        opacity: 1.0
                        z: 2
                    }
                },
                State {
                    name: "inactive"
                    when: !desktopRoot.showChannel1
                    PropertyChanges {
                        target: bg1
                        opacity: 0.0
                        z: 1
                    }
                }
            ]

            transitions: [
                // الظهور: يغطي القديم فوراً
                Transition {
                    from: "inactive"
                    to: "active"
                    NumberAnimation {
                        property: "opacity"
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }
                },
                // الاختفاء: ينتظر حتى تكتمل الصورة الجديدة
                Transition {
                    from: "active"
                    to: "inactive"
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 800
                        }
                        PropertyAction {
                            property: "opacity"
                            value: 0.0
                        }
                    }
                }
            ]
        }

        Image {
            id: bg2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)

            // === نفس المنطق للقناة الثانية ===
            states: [
                State {
                    name: "active"
                    when: !desktopRoot.showChannel1
                    PropertyChanges {
                        target: bg2
                        opacity: 1.0
                        z: 2
                    }
                },
                State {
                    name: "inactive"
                    when: desktopRoot.showChannel1
                    PropertyChanges {
                        target: bg2
                        opacity: 0.0
                        z: 1
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "inactive"
                    to: "active"
                    NumberAnimation {
                        property: "opacity"
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }
                },
                Transition {
                    from: "active"
                    to: "inactive"
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 800
                        }
                        PropertyAction {
                            property: "opacity"
                            value: 0.0
                        }
                    }
                }
            ]
        }
    }

    // ---------------------------------------------------------
    // 4. تحميل الساعة
    // ---------------------------------------------------------
    Loader {
        id: clockLoader
        z: 1
        active: clockSettings?.enabled || false
        sourceComponent: clockComponent

        transformOrigin: Item.Center
        scale: 1.0
        opacity: 1.0

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
            desktopRoot.currentClockPosition = desktopRoot.themeClockPosition;
            desktopRoot.currentClockSize = desktopRoot.themeClockSize;
        }
    }

    Component {
        id: clockComponent
        DesktopClock {
            id: theClock
            position: desktopRoot.currentClockPosition
            size: desktopRoot.currentClockSize
            editMode: false

            clockColor: clockSettings?.useThemeColor ? Theme.ThemeManager.selectedTheme.colors.primary.alpha(0.7) : (clockSettings?.color || "white")
            clockFont: clockSettings?.font || "Arial"
            clockFormat: clockSettings?.format || "hh:mm:ss"
            clockLocale: clockSettings?.local || "en_US"
            enableAnimation: clockSettings?.enableAnimation || false
            shadowEnabled: clockSettings?.shadowEnabled || false
            shadowColor: clockSettings?.shadowColor || "black"

            onRequestNewGeometry: (newPosition, newSize) => {
                desktopRoot.currentClockPosition = newPosition;
                desktopRoot.currentClockSize = newSize;
            }

            onEditModeChanged: {
                if (!editMode) {
                    Theme.ThemeManager.updateAndApplyTheme({
                        "_desktopClockPosition": desktopRoot.currentClockPosition,
                        "_desktopClockSize": desktopRoot.currentClockSize
                    }, true);
                }
            }
        }
    }

    // ---------------------------------------------------------
    // 5. طبقة العمق (Foreground Layer) - عادت كما كانت (Behavior بسيط)
    // ---------------------------------------------------------
    Item {
        id: foregroundLayer
        z: 2
        anchors.fill: parent

        property bool shouldBeVisible: (clockSettings?.enabled && clockSettings?.depthEffectEnabled) || false
        opacity: shouldBeVisible ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 600
                easing.type: Easing.InOutQuad
            }
        }

        transformOrigin: Item.Center
        scale: 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuart
            }
        }

        Image {
            id: fg1
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)

            // عودة للمنطق البسيط (Cross-fade) لأنه أفضل للشفافية
            opacity: desktopRoot.showChannel1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: fg2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)

            // عودة للمنطق البسيط
            opacity: !desktopRoot.showChannel1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // ---------------------------------------------------------
    // 6. المنطق والمزامنة
    // ---------------------------------------------------------
    Timer {
        id: cleanupTimer
        interval: 900
        repeat: false
        onTriggered: {
            if (desktopRoot.showChannel1) {
                bg2.source = "";
                fg2.source = "";
            } else {
                bg1.source = "";
                fg1.source = "";
            }
        }
    }

    function checkReadinessAndSwap() {
        let pendingBg = desktopRoot.showChannel1 ? bg2 : bg1;
        let pendingFg = desktopRoot.showChannel1 ? fg2 : fg1;
        let depthEnabled = (clockSettings?.enabled && clockSettings?.depthEffectEnabled) || false;

        let bgReady = (pendingBg.status === Image.Ready);
        let fgReady = !depthEnabled || (pendingFg.status === Image.Ready) || (desktopRoot.targetOverlay === "");

        if (bgReady && fgReady) {
            desktopRoot.showChannel1 = !desktopRoot.showChannel1;
            cleanupTimer.restart();
        }
    }

    Connections {
        target: bg1
        function onStatusChanged() {
            if (!desktopRoot.showChannel1)
                desktopRoot.checkReadinessAndSwap();
        }
    }
    Connections {
        target: bg2
        function onStatusChanged() {
            if (desktopRoot.showChannel1)
                desktopRoot.checkReadinessAndSwap();
        }
    }
    Connections {
        target: fg1
        function onStatusChanged() {
            if (!desktopRoot.showChannel1)
                desktopRoot.checkReadinessAndSwap();
        }
    }
    Connections {
        target: fg2
        function onStatusChanged() {
            if (desktopRoot.showChannel1)
                desktopRoot.checkReadinessAndSwap();
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: {
            if (clockLoader.item?.editMode) {
                clockLoader.item.editMode = false;
            }
        }
    }

    // ---------------------------------------------------------
    // 7. الاتصال بمدير الثيمات
    // ---------------------------------------------------------
    Connections {
        target: Theme.ThemeManager
        function onSelectedThemeUpdated() {
            if (clockSettings?.enabled) {
                let newPos = desktopRoot.themeClockPosition;
                let newSize = desktopRoot.themeClockSize;
                if (newSize.width > 0) {
                    desktopRoot.currentClockPosition = newPos;
                    desktopRoot.currentClockSize = newSize;
                }
            }

            let newWall = Theme.ThemeManager.getCurrentWallpaper();
            let newOverlay = (clockSettings?.depthEffectEnabled) ? (clockSettings?.depthOverlayPath || "") : "";

            desktopRoot.targetWallpaper = newWall;
            desktopRoot.targetOverlay = newOverlay;

            if (desktopRoot.showChannel1) {
                bg2.source = newWall;
                fg2.source = newOverlay;
            } else {
                bg1.source = newWall;
                fg1.source = newOverlay;
            }
            desktopRoot.checkReadinessAndSwap();
        }
    }

    // ---------------------------------------------------------
    // 8. دوال الأنيميشن
    // ---------------------------------------------------------
    function onMenuOpened() {
        if (backgroundLayer)
            backgroundLayer.scale = 1.05;
        if (foregroundLayer)
            foregroundLayer.scale = 1.10;
        if (clockLoader) {
            clockLoader.opacity = 0.8;
            clockLoader.scale = 0.85;
        }
    }

    function onMenuClosed() {
        if (backgroundLayer)
            backgroundLayer.scale = 1.0;
        if (foregroundLayer)
            foregroundLayer.scale = 1.0;
        if (clockLoader) {
            clockLoader.opacity = 1.0;
            clockLoader.scale = 1.0;
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, onMenuOpened);
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, onMenuClosed);

        if (clockSettings?.enabled) {
            desktopRoot.currentClockPosition = desktopRoot.themeClockPosition;
            desktopRoot.currentClockSize = desktopRoot.themeClockSize;
        }
        let startWall = Theme.ThemeManager.getCurrentWallpaper();
        let startOverlay = (clockSettings?.depthEffectEnabled) ? (clockSettings?.depthOverlayPath || "") : "";
        bg1.source = startWall;
        fg1.source = startOverlay;
        showChannel1 = true;
    }

    Component.onDestruction: {
        try {
            EventBus.off(Events.LEFT_MENU_IS_OPENED, onMenuOpened);
            EventBus.off(Events.LEFT_MENU_IS_CLOSED, onMenuClosed);
        } catch (err) {}
    }
}

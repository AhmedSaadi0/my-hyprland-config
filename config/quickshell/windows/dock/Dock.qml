// windows/dock/Dock.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "root:/config/ConstValues.js" as C        // <-- 1. إضافة استيراد الثوابت
import "root:/utils"

PanelWindow {
    id: root

    visible: App.showDock && modelData.name === Hyprland.focusedMonitor.name
    color: "transparent"
    focusable: root.anyMenuOpen
    exclusionMode: ExclusionMode.Ignore

    // WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "NibrasShell:dock"

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        bottom: 0
    }

    readonly property int dockHeightToShow: App.dockIconSize + 48
    // مساحة زائدة كبيرة لضمان حجز حرية الانزلاق بدون قص الـ Window من خوادم Wayland
    implicitHeight: dockHeightToShow + 250

    // --- State & Display Logic ---
    property bool mouseHovered: false
    property bool hasAppsOnWorkspace: App.hasWindowsOnWorkspace
    property bool anyMenuOpen: false
    property var currentOpenPopup: null
    property bool isBottomLauncherOpen: false
    property bool isLeftMenuOpen: false         // <-- 2. متغير حالة لمراقبة فتح القائمة اليسرى

    readonly property bool shouldDockBeRevealed: !hasAppsOnWorkspace || root.mouseHovered || root.anyMenuOpen || root.isBottomLauncherOpen

    property bool effectiveHasApps: false

    Timer {
        id: colorTransitionTimer
        interval: 500
        onTriggered: {
            root.effectiveHasApps = true;
        }
    }

    Connections {
        target: root
        function onHasAppsOnWorkspaceChanged() {
            if (root.hasAppsOnWorkspace) {
                colorTransitionTimer.restart();
            } else {
                colorTransitionTimer.stop();
                root.effectiveHasApps = false;
            }
        }
        function onAnyMenuOpenChanged() {
            if (!root.anyMenuOpen && !globalWindowTracker.hovered) {
                hideDebounceTimer.restart();
            }
        }
    }

    property int updateTrigger: 0
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "openwindow" || event.name === "closewindow" || event.name === "movewindow" || event.name === "activewindow") {
                root.updateTrigger++;
            }
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.BOTTOM_LAUNCHER_OPENED, () => {
            root.isBottomLauncherOpen = true;
        }, root);
        EventBus.on(Events.BOTTOM_LAUNCHER_CLOSED, () => {
            root.isBottomLauncherOpen = false;
        }, root);

        // <-- 3. الاستماع لأحداث القائمة لتعديل حالة المتغير
        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            root.isLeftMenuOpen = true;
        }, root);
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            root.isLeftMenuOpen = false;
        }, root);
    }

    // =========================================================
    // 1. نظام القناع المركزي المرتبط بسير النوافذ (The Unified Shape)
    // =========================================================
    mask: anyMenuOpen ? null : dockMaskRegion

    Region {
        id: dockMaskRegion

        // المنطقة الأولى: الخيط التحفيزي الموجود دائماً
        Region {
            item: bottomTriggerArea
        }

        // المنطقة الثانية: الجسر الآمن ومربع الكبسولة (يفعلان فقط حين يبدأ بالصعود لمنع سقوط التفاعل)
        Region {
            item: shouldDockBeRevealed ? dockContainer : null
        }
        Region {
            item: shouldDockBeRevealed ? connectionBridge : null
        }
    }

    // قطع الاتصال والتوصيل الوهمية للمراقبة الموحدة بدون سرقة التفاعل من الأب
    Item {
        id: trackingNodes
        anchors.fill: parent

        // الخط الرقيق لتعريض تحسس النافذة
        Rectangle {
            id: bottomTriggerArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: "transparent"
        }

        // الكتلة الوهمية: تعمل كجسر ممر آمِن لاختصار فراغات الشاشة وتجنب سقوط حالة التحويم بالمرور للمنتصف
        Rectangle {
            id: connectionBridge
            x: dockContainer.x - 20
            y: dockContainer.y - 20 // يغلف أطراف الدوك نفسها قليلاً
            width: dockContainer.width + 40
            height: root.height - y // واصل للأسفل دوماً كحصن
            color: "transparent"
        }
    }

    // =========================================================
    // 2. المحرك المراقِب الديكتاتوري والمحيد لكل التجاذبات الداخلية (The Omni-Observer)
    // =========================================================
    HoverHandler {
        id: globalWindowTracker
        onHoveredChanged: {
            if (hovered) {
                // إغلاق المؤقت فوراً وتجميد ظهوره بمجرد اللمس
                hideDebounceTimer.stop();
                root.mouseHovered = true;
            } else {
                // الفأرة غادرت حرفياً كامل التجاويف الجسرية وشاشة الكبسولة والنافذة برمتها - يُبدأ العد التنازلي لإخفاء آمن
                hideDebounceTimer.restart();
            }
        }
    }

    Timer {
        id: hideDebounceTimer
        interval: 350
        onTriggered: {
            // نأمن عدم اختفاء الـ Dock أثناء تفريز المستخدم قائمة اليمين المفتوحة (AnyMenu)
            if (!root.anyMenuOpen) {
                root.mouseHovered = false;
            }
        }
    }

    // --- دوال المطابقة وجلب العمليات قمت بتبسيط أداءها---
    function resolveAppData(appId) {
        if (!DesktopEntries || !appId)
            return null;
        if (typeof DesktopEntries.heuristicLookup === "function") {
            let heuristicEntry = DesktopEntries.heuristicLookup(appId);
            if (heuristicEntry)
                return heuristicEntry;
        }

        let entry = DesktopEntries.byId(appId) || (appId.endsWith(".desktop") ? DesktopEntries.byId(appId + ".desktop") : null);
        if (entry)
            return entry;

        let lowerId = appId.toLowerCase();
        let apps = DesktopEntries.applications.values;
        for (let i = 0; i < apps.length; i++) {
            let app = apps[i];
            if (app && ((app.id && app.id.toLowerCase() === lowerId) || (app.name && app.name.toLowerCase() === lowerId) || (app.startupClass && app.startupClass.toLowerCase() === lowerId))) {
                return app;
            }
        }
        return null;
    }

    readonly property var runningApps: {
        let dummy = root.updateTrigger;
        let dummyCount = Hyprland.toplevels.count;
        let apps = {};
        let toplevels = Hyprland.toplevels.values;

        for (let i = 0; i < toplevels.length; i++) {
            let win = toplevels[i];
            if (!win)
                continue;
            let appId = win.appId || (win.lastIpcObject ? win.lastIpcObject.class : "") || "unknown";
            let rawAddr = String(win.address || "");
            if (!rawAddr)
                continue;
            let addr = rawAddr.startsWith("0x") ? rawAddr : "0x" + rawAddr;

            if (!apps[appId])
                apps[appId] = {
                    appId: appId,
                    count: 1,
                    address: addr
                };
            else
                apps[appId].count++;
        }
        return Object.values(apps);
    }

    readonly property var dockItems: {
        let dummy = root.updateTrigger;
        let items = [];
        let favs = App.dockApps || [];
        let running = runningApps;
        let seen = {};

        items.push({
            isLauncher: true
        });

        for (let i = 0; i < favs.length; i++) {
            let favId = favs[i];
            let runningInfo = running.find(r => r.appId === favId);
            items.push({
                appId: favId,
                appData: resolveAppData(favId),
                isPinnedToDock: true,
                isRunning: runningInfo !== undefined,
                windowAddress: runningInfo ? runningInfo.address : "",
                instanceCount: runningInfo ? runningInfo.count : 0
            });
            seen[favId] = true;
        }

        let hasNonFavRunning = running.some(r => !seen[r.appId]);
        if (favs.length > 0 && hasNonFavRunning) {
            items.push({
                isSeparator: true
            });
        }

        for (let i = 0; i < running.length; i++) {
            let r = running[i];
            if (!seen[r.appId]) {
                items.push({
                    appId: r.appId,
                    appData: resolveAppData(r.appId),
                    isPinnedToDock: false,
                    isRunning: true,
                    windowAddress: r.address,
                    instanceCount: r.count
                });
                seen[r.appId] = true;
            }
        }
        return items;
    }

    MouseArea {
        anchors.fill: parent
        visible: root.anyMenuOpen
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        focus: true
        Keys.onEscapePressed: {
            if (root.currentOpenPopup) {
                root.currentOpenPopup.close();
            }
        }
        onClicked: {
            if (root.currentOpenPopup) {
                root.currentOpenPopup.close();
            }
        }
    }

    // =========================================================
    // 3. مسرح العرض (الكبسولة والنزول الداخلي المُفصّل بانسيابية)
    // =========================================================
    Rectangle {
        id: dockContainer
        anchors.horizontalCenter: parent.horizontalCenter

        // 4. تطبيق الإزاحة الأفقية المتناسبة مع حالة القائمة اليسرى ليتطابق التحرك مع سطح المكتب والنوتش
        anchors.horizontalCenterOffset: App.menuStyle !== C.FLOATING && root.isLeftMenuOpen ? ThemeManager.selectedTheme.dimensions.menuWidth + 5 : 0

        // تطبيق الأنيميشن بنفس معايير منحنى التسارع ومعدل الوقت لسطح المكتب
        Behavior on anchors.horizontalCenterOffset {
            NumberAnimation {
                duration: AnimationConfig.animDuration
                easing.type: Easing.Bezier
                easing.bezierCurve: AnimationConfig.bezierAccelerate
            }
        }

        // الانزياح الحركي المحصور للأنيميشن داخل النطاق الخاص المتروك عبر Implicit Height دون التأثير المفرط!
        y: shouldDockBeRevealed ? (root.height - height - 12) : (root.height + 20)

        width: dockRow.childrenRect.width + 24
        onWidthChanged: EventBus.emit(Events.DOCK_WIDTH_CHANGED, width)
        height: App.dockIconSize + 32
        radius: effectiveHasApps ? ThemeManager.selectedTheme.dimensions.elementRadius * 1.5 : 24
        visible: true

        color: effectiveHasApps ? ThemeManager.selectedTheme.colors.surface : "transparent"
        border.color: effectiveHasApps ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"
        border.width: effectiveHasApps ? 1 : 0

        Behavior on y {
            SpringAnimation {
                spring: 2.8
                damping: 0.6
                epsilon: 0.1
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        layer.enabled: hasAppsOnWorkspace
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: ThemeManager.selectedTheme.colors.shadow.alpha(0.5)
            shadowBlur: 0.8
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
            shadowScale: 1.0
        }

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: dockItems

                delegate: Loader {
                    active: true
                    readonly property var itemData: modelData
                    sourceComponent: itemData.isSeparator ? separatorComponent : itemData.isLauncher ? launcherComponent : dockItemComponent

                    Component {
                        id: separatorComponent
                        Rectangle {
                            width: 1
                            height: App.dockIconSize + 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: ThemeManager.selectedTheme.colors.outlineVariant
                        }
                    }

                    Component {
                        id: launcherComponent
                        Rectangle {
                            width: App.dockIconSize + 16
                            height: App.dockIconSize + 16
                            radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.8
                            color: launcherMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.12) : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰀻"
                                font.family: ThemeManager.selectedTheme.typography.iconFont
                                font.pixelSize: App.dockIconSize * 0.65
                                color: ThemeManager.selectedTheme.colors.onSurface
                            }

                            MouseArea {
                                id: launcherMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    EventBus.emit(Events.TOGGLE_BOTTOM_LAUNCHER);
                                }
                            }
                        }
                    }

                    Component {
                        id: dockItemComponent
                        DockItem {
                            appId: itemData.appId || ""
                            appData: itemData.appData || null
                            isRunning: itemData.isRunning || false
                            windowAddress: itemData.windowAddress || ""
                            instanceCount: itemData.instanceCount || 0
                            isPinnedToDock: itemData.isPinnedToDock || false
                            tooltipText: itemData.appId || ""
                            iconSize: App.dockIconSize
                            panelWindow: root
                        }
                    }
                }
            }
        }
    }
}

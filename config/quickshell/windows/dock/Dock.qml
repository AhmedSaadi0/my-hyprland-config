// windows/dock/Dock.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "root:/config/ConstValues.js" as C
import "root:/utils"
import "root:/services"

PanelWindow {
    id: root

    visible: App.showDock && modelData.name === Hyprland.focusedMonitor.name
    color: "transparent"
    focusable: root.anyMenuOpen
    exclusionMode: ExclusionMode.Ignore

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
    implicitHeight: dockHeightToShow + 250

    // --- State & Display Logic ---
    property bool mouseHovered: false
    property bool hasAppsOnWorkspace: App.hasWindowsOnWorkspace
    property bool anyMenuOpen: false
    property bool anyDockTooltipVisible: false
    property var currentOpenPopup: null
    property bool isBottomLauncherOpen: false
    property bool isLeftMenuOpen: false

    readonly property bool shouldDockBeRevealed: !hasAppsOnWorkspace || root.mouseHovered || root.anyMenuOpen || root.isBottomLauncherOpen

    property bool effectiveHasApps: false

    // Request icon resolution from IconService when dock items change
    onDockItemsChanged: _requestDockIcons()

    function _requestDockIcons() {
        let items = root.dockItems || [];
        let iconNames = [];
        for (let i = 0; i < items.length; i++) {
            let item = items[i];
            if (item.isLauncher || item.isSeparator || !item.appId)
                continue;
            let iconKey = item.appData ? item.appData.icon : item.appId;
            if (!Helper.isDirectImageSource(iconKey))
                iconNames.push(iconKey);
        }
        if (iconNames.length > 0)
            IconService.requestResolve(iconNames);
    }

    Timer {
        id: colorTransitionTimer
        interval: 300
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
    property bool _pendingUpdate: false

    onUpdateTriggerChanged: _rebuildRunningApps()

    Timer {
        id: batchUpdateTimer
        interval: 100
        repeat: false
        onTriggered: {
            root._pendingUpdate = false;
            root.updateTrigger++;
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "openwindow" || event.name === "closewindow") {
                root.updateTrigger++;
            } else if (event.name === "activewindow" || event.name === "movewindow") {
                if (!root._pendingUpdate) {
                    root._pendingUpdate = true;
                    batchUpdateTimer.start();
                }
            }
        }
    }

    Component.onCompleted: {
        _rebuildRunningApps();
        EventBus.on(Events.BOTTOM_LAUNCHER_OPENED, () => {
            root.isBottomLauncherOpen = true;
        }, root);
        EventBus.on(Events.BOTTOM_LAUNCHER_CLOSED, () => {
            root.isBottomLauncherOpen = false;
        }, root);

        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            root.isLeftMenuOpen = true;
        }, root);
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            root.isLeftMenuOpen = false;
        }, root);

        EventBus.on(Events.DOCK_APPS_CHANGED, () => {
            root.updateTrigger++;
        }, root);
    }

    mask: (anyMenuOpen || anyDockTooltipVisible) ? null : dockMaskRegion

    Region {
        id: dockMaskRegion
        Region {
            item: bottomTriggerArea
        }
        Region {
            item: shouldDockBeRevealed ? dockContainer : null
        }
        Region {
            item: shouldDockBeRevealed ? connectionBridge : null
        }
    }

    Item {
        id: trackingNodes
        anchors.fill: parent
        Rectangle {
            id: bottomTriggerArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 4
            color: "transparent"
        }
        Rectangle {
            id: connectionBridge
            x: dockContainer.x - 20
            y: dockContainer.y - 20
            width: dockContainer.width + 40
            height: root.height - y
            color: "transparent"
        }
    }

    HoverHandler {
        id: globalWindowTracker
        onHoveredChanged: {
            if (hovered) {
                hideDebounceTimer.stop();
                root.mouseHovered = true;
            } else {
                hideDebounceTimer.restart();
            }
        }
    }

    Timer {
        id: hideDebounceTimer
        interval: 350
        onTriggered: {
            if (!root.anyMenuOpen) {
                root.mouseHovered = false;
            }
        }
    }

    function resolveAppData(appId) {
        if (!DesktopEntries || !appId)
            return null;

        let entry = DesktopEntries.byId(appId);
        if (entry)
            return entry;

        if (!appId.endsWith(".desktop")) {
            entry = DesktopEntries.byId(appId + ".desktop");
            if (entry)
                return entry;
        }

        let lowerId = appId.toLowerCase();
        let apps = DesktopEntries.applications.values;
        for (let i = 0; i < apps.length; i++) {
            let app = apps[i];
            if (app && app.id && app.id.toLowerCase() === lowerId) {
                return app;
            }
        }
        return null;
    }

    property var _cachedRunningApps: []

    function _rebuildRunningApps() {
        let apps = {};
        let toplevels = Hyprland.toplevels.values;

        for (let i = 0; i < toplevels.length; i++) {
            let win = toplevels[i];
            if (!win)
                continue;
            let appId = win.appId || (win.lastIpcObject ? win.lastIpcObject.class : "") || "unknown";
            if (appId === "unknown")
                continue;
            let rawAddr = String(win.address || "");
            if (!rawAddr)
                continue;
            let addr = rawAddr.startsWith("0x") ? rawAddr : "0x" + rawAddr;
            let wsId = (win.workspace && win.workspace.id !== undefined) ? win.workspace.id : -1;

            if (!apps[appId])
                apps[appId] = {
                    appId: appId,
                    count: 1,
                    windows: [
                        {
                            address: addr,
                            workspaceId: wsId
                        }
                    ]
                };
            else {
                apps[appId].count++;
                apps[appId].windows.push({
                    address: addr,
                    workspaceId: wsId
                });
            }
        }
        root._cachedRunningApps = Object.values(apps);
    }

    readonly property var runningApps: root._cachedRunningApps

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
                windowAddress: runningInfo ? runningInfo.windows[0].address : "",
                instanceCount: runningInfo ? runningInfo.count : 0,
                windows: runningInfo ? runningInfo.windows : []
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
                    windowAddress: r.windows[0].address,
                    instanceCount: r.count,
                    windows: r.windows
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

    Item {
        id: dockContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: App.menuStyle !== C.FLOATING && root.isLeftMenuOpen ? ThemeManager.selectedTheme.dimensions.menuWidth + 5 : 0

        Behavior on anchors.horizontalCenterOffset {
            NumberAnimation {
                duration: AnimationConfig.animDuration
                easing.type: Easing.Bezier
                easing.bezierCurve: AnimationConfig.bezierAccelerate
            }
        }

        y: shouldDockBeRevealed ? (root.height - height - 12) : (root.height + 20)
        width: dockRow.childrenRect.width + 24
        onWidthChanged: EventBus.emit(Events.DOCK_WIDTH_CHANGED, width)
        height: App.dockIconSize + 32
        visible: true

        Behavior on y {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        Rectangle {
            id: dockBackground
            anchors.fill: parent
            radius: effectiveHasApps ? ThemeManager.selectedTheme.dimensions.elementRadius * 1.5 : 24
            color: effectiveHasApps ? ThemeManager.selectedTheme.colors.surface : "transparent"
            border.color: effectiveHasApps ? ThemeManager.selectedTheme.colors.primary.alpha(0.5) : "transparent"
            border.width: effectiveHasApps ? 2 : 0

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
                            windows: itemData.windows || []
                        }
                    }
                }
            }
        }
    }
}

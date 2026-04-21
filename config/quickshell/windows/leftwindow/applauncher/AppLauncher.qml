// windows/leftwindow/applauncher/AppLauncher.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Apps")
    menuIcon: "󰀻"
    showPrimaryAction: false

    // Ensure the menu itself takes the full available height and width
    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property var dims: ThemeManager.selectedTheme.dimensions

    // --- Base Launcher Instance ---
    BaseLauncher {
        id: baseLauncher

        // Managed centrally in BaseLauncher via searchText
        selectedCategory: categoryFilter.selectedCategory

        // Override shared functions with implementations
        function toggleFavorite(appData) {
            const appId = appData.name;
            const index = App.favoriteApps.indexOf(appId);
            if (index === -1) {
                App.favoriteApps.push(appId);
            } else {
                App.favoriteApps.splice(index, 1);
            }
            App.updateConfig("favoriteApps", App.favoriteApps);
        }

        function isFavorite(appData) {
            const appId = appData.name;
            return App.favoriteApps.indexOf(appId) !== -1;
        }

        function executeCommand(cmd) {
            if (cmd.enabled === false)
                return;
            if (cmd.isAction) {
                if (cmd.action === "openSettings") {
                    EventBus.emit(Events.OPEN_SETTINGS);
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                } else if (cmd.action === "nextWallpaper") {
                    ThemeManager.switchToNextWallpaper();
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                } else if (cmd.action === "previousWallpaper") {
                    ThemeManager.switchToPreviousWallpaper();
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                }
            } else if (cmd.view !== "") {
                activeCommandView = cmd.view;
            }
        }

        function launchApp(command, workingDirectory) {
            clearSearchText.stop();
            Quickshell.execDetached({
                command: command,
                workingDirectory: workingDirectory
            });
            clearSearchText.start();
            EventBus.emit(Events.CLOSE_LEFTBAR);
        }

        function ensureAppSelection() {
            if (baseLauncher.isCommandMode || baseLauncher.activeCommandView !== "") {
                baseLauncher.selectedAppIndex = -1;
                return;
            }
            if (!isSelectableAppIndex(baseLauncher.selectedAppIndex)) {
                baseLauncher.selectedAppIndex = firstSelectableAppIndex();
            }
        }

        function ensureCommandSelection() {
            if (!baseLauncher.isCommandMode || baseLauncher.filteredCommands.length === 0) {
                baseLauncher.selectedCommandIndex = -1;
                return;
            }
            if (baseLauncher.selectedCommandIndex < 0 || baseLauncher.selectedCommandIndex >= baseLauncher.filteredCommands.length) {
                baseLauncher.selectedCommandIndex = 0;
            }
        }

        function moveSelection(dir) {
            if (baseLauncher.isCommandMode) {
                moveCommandSelection(dir);
                return;
            }
            if (baseLauncher.activeCommandView !== "")
                return;
            if (baseLauncher.filteredAppsModel.values.length === 0)
                return;
            let idx = baseLauncher.selectedAppIndex;
            if (idx < 0)
                idx = dir > 0 ? 0 : baseLauncher.filteredAppsModel.values.length - 1;
            else
                idx = Math.max(0, Math.min(baseLauncher.filteredAppsModel.values.length - 1, idx + dir));
            baseLauncher.selectedAppIndex = idx;
        }

        function moveCommandSelection(dir) {
            if (baseLauncher.filteredCommands.length === 0)
                return;
            let idx = baseLauncher.selectedCommandIndex;
            if (idx < 0)
                idx = dir > 0 ? 0 : baseLauncher.filteredCommands.length - 1;
            else
                idx = Math.max(0, Math.min(baseLauncher.filteredCommands.length - 1, idx + dir));
            baseLauncher.selectedCommandIndex = idx;
        }

        function firstEnabledCommandIndex(startIdx) {
            if (baseLauncher.filteredCommands.length === 0)
                return -1;
            let idx = Math.max(0, Math.min(baseLauncher.filteredCommands.length - 1, startIdx));
            for (let i = idx; i < baseLauncher.filteredCommands.length; i++) {
                if (baseLauncher.filteredCommands[i].enabled !== false)
                    return i;
            }
            for (let i = idx - 1; i >= 0; i--) {
                if (baseLauncher.filteredCommands[i].enabled !== false)
                    return i;
            }
            return -1;
        }

        function activateSelection() {
            if (baseLauncher.isCommandMode) {
                activateCommandSelection();
                return;
            }
            if (baseLauncher.activeCommandView !== "")
                return;
            let idx = baseLauncher.selectedAppIndex;
            if (idx < 0)
                idx = 0;
            if (idx < 0 || idx >= baseLauncher.filteredAppsModel.values.length)
                return;
            const app = baseLauncher.filteredAppsModel.values[idx];
            if (!app)
                return;
            baseLauncher.launchApp(app.command, app.workingDirectory);
        }

        function activateCommandSelection() {
            if (baseLauncher.filteredCommands.length === 0)
                return;
            let idx = baseLauncher.selectedCommandIndex >= 0 ? baseLauncher.selectedCommandIndex : 0;
            idx = firstEnabledCommandIndex(idx);
            if (idx === -1)
                return;
            baseLauncher.executeCommand(baseLauncher.filteredCommands[idx]);
        }

        function resetState() {
            appsHeader.searchText = "";
            baseLauncher.searchText = "";
            baseLauncher.activeCommandView = "";
            baseLauncher.selectedAppIndex = -1;
            baseLauncher.selectedCommandIndex = -1;
        }

        function doGainFocus() {
            forceActiveFocus();
            focusTimer.start();
        }

        Timer {
            id: focusTimer
            interval: 10
            repeat: false
            onTriggered: appsHeader.forceSearchFocus()
        }

        Timer {
            id: clearSearchText
            interval: 100
            repeat: false
            onTriggered: {
                appsHeader.searchText = "";
                baseLauncher.searchText = "";
                baseLauncher.activeCommandView = "";
            }
        }
    }

    // ==========================================================================
    // Original AppLauncher Specific Logic and UI
    // ==========================================================================

    // --- Header Section ---
    headerContent: AppsHeader {
        id: appsHeader
        width: root.width

        onSearchTextChanged: {
            // Sync to source of truth
            baseLauncher.searchText = appsHeader.searchText;
            Qt.callLater(baseLauncher.ensureCommandSelection);
            Qt.callLater(baseLauncher.ensureAppSelection);
        }

        onMoveSelection: dir => baseLauncher.moveSelection(dir)
        onActivateSelection: baseLauncher.activateSelection()
        onEscapePressed: {
            if (baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
                appsHeader.searchText = "";
                baseLauncher.searchText = "";
                appsHeader.forceSearchFocus();
            }
        }
    }

    // --- Main Content Area ---
    SwipeView {
        id: viewStack
        Layout.fillWidth: true
        Layout.fillHeight: true

        Layout.preferredHeight: root.height > 150 ? root.height - 150 : 500
        implicitHeight: 0

        Layout.leftMargin: root.dims.menuWidgetsMargin
        Layout.rightMargin: root.dims.menuWidgetsMargin
        Layout.bottomMargin: root.dims.menuWidgetsMargin

        currentIndex: baseLauncher.currentViewIndex
        interactive: false
        clip: true
        orientation: Qt.Horizontal

        // Page 0: App List
        AppsList {
            id: appsList
            listModel: baseLauncher.filteredAppsModel.values
            selectedIndex: baseLauncher.selectedAppIndex

            onCategoryChanged: Qt.callLater(baseLauncher.ensureAppSelection)
            onAppClicked: (index, appData) => {
                baseLauncher.selectedAppIndex = index;
                baseLauncher.launchApp(appData.command, appData.workingDirectory);
            }
        }

        // Page 1: Command List
        CommandsList {
            id: commandsList
            listModel: baseLauncher.filteredCommands
            selectedIndex: baseLauncher.selectedCommandIndex

            onCommandClicked: cmdData => baseLauncher.executeCommand(cmdData)
        }

        // Page 2: Wallpaper Selector
        Item {
            WallpaperSelector {
                id: wallpaperSelector
                anchors.fill: parent

                onWallpaperSelected: path => {
                    baseLauncher.activeCommandView = "";
                    appsHeader.searchText = "";
                    baseLauncher.searchText = "";
                    appsHeader.forceSearchFocus();
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                }
                onCloseRequested: {
                    baseLauncher.activeCommandView = "";
                    appsHeader.searchText = "";
                    baseLauncher.searchText = "";
                    appsHeader.forceSearchFocus();
                }
            }
        }
    }

    // --- Global Key Handling (When not focused on search) ---
    Keys.onPressed: event => {
        if (event.text && !appsHeader.activeFocus) {
            appsHeader.appendText(event.text);
            // Manually sync since appendText is called
            baseLauncher.searchText = appsHeader.searchText;
            focusTimer.start();
            event.accepted = true;
        }
    }

    onVisibleChanged: {
        if (!visible)
            baseLauncher.resetState();
    }

    Item {
        id: categoryFilter
        // dummy for mapping, or you can add real logic if needed
        property string selectedCategory: ""
    }

    function isSelectableAppIndex(idx) {
        return idx >= 0 && idx < baseLauncher.filteredAppsModel.values.length;
    }

    function firstSelectableAppIndex() {
        return baseLauncher.filteredAppsModel.values.length > 0 ? 0 : -1;
    }

    Connections {
        target: baseLauncher
        function onIsCommandModeChanged() {
            if (!baseLauncher.isCommandMode && baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
            }
            baseLauncher.ensureCommandSelection();
            baseLauncher.ensureAppSelection();
        }
    }

    // Forward the appLaunched signal from baseLauncher
    Connections {
        target: baseLauncher
        function onAppLaunched() {
            // In Left App Launcher, we normally close the bar when an app is launched
            EventBus.emit(Events.CLOSE_LEFTBAR);
        }
    }
}
// components/BaseLauncher.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events

Item {
    id: root

    // ==========================================================================
    // Shared Properties
    // ==========================================================================

    // --- Search State ---
    property string searchText: ""
    property string selectedCategory: ""

    // --- Command Mode Properties ---
    property bool isCommandMode: CommandsRegistry.isCommandMode(searchText)
    property string commandText: CommandsRegistry.getCommandText(searchText)
    property var filteredCommands: isCommandMode ? CommandsRegistry.filterCommands(commandText) : []

    // --- View State ---
    property string activeCommandView: ""
    property int selectedAppIndex: -1
    property int selectedCommandIndex: -1

    // --- Computed property for view index ---
    property int currentViewIndex: {
        if (activeCommandView === "wallpaper")
            return 2;
        if (isCommandMode)
            return 1;
        return 0;
    }

    // ==========================================================================
    // Shared Functions (to be overridden or used as-is by consumers)
    // ==========================================================================

    // --- Favorites Management ---
    function toggleFavorite(appData) {
        // Default implementation - can be overridden by consumer
        if (typeof App !== 'undefined' && appData && appData.name) {
            const appId = appData.name;
            const index = App.favoriteApps.indexOf(appId);
            if (index === -1) {
                App.favoriteApps.push(appId);
            } else {
                App.favoriteApps.splice(index, 1);
            }
            App.updateConfig("favoriteApps", App.favoriteApps);
        }
    }

    function isFavorite(appData) {
        // Default implementation - can be overridden by consumer
        if (typeof App !== 'undefined' && appData && appData.name) {
            const appId = appData.name;
            return App.favoriteApps.indexOf(appId) !== -1;
        }
        return false;
    }

    // --- Command Execution ---
    function executeCommand(cmd) {
        // Default implementation - can be overridden by consumer
        if (cmd && cmd.enabled !== false) {
            if (cmd.isAction) {
                if (cmd.action === "openSettings") {
                    EventBus.emit(Events.OPEN_SETTINGS);
                } else if (cmd.action === "nextWallpaper") {
                    ThemeManager.switchToNextWallpaper();
                } else if (cmd.action === "previousWallpaper") {
                    ThemeManager.switchToPreviousWallpaper();
                }
            } else if (cmd.view !== "") {
                activeCommandView = cmd.view;
            }
        }
    }

    function launchApp(command, workingDirectory) {
        // Default implementation - can be overridden by consumer
        if (command) {
            Quickshell.execDetached({
                command: command,
                workingDirectory: workingDirectory
            });
        }
    }

    // --- Selection Management (default implementations) ---
    function ensureAppSelection() {
    // To be implemented by consumer if needed
    }

    function ensureCommandSelection() {
    // To be implemented by consumer if needed
    }

    function moveSelection(dir) {
    // To be implemented by consumer if needed
    }

    function activateSelection() {
    // To be implemented by consumer if needed
    }

    function resetState() {
    // To be implemented by consumer if needed
    }

    // ==========================================================================
    // Shared Timers
    // ==========================================================================

    Timer {
        id: focusTimer
        interval: 10
        running: false
        repeat: false
        onTriggered:
        // To be implemented by consumer
        {}
    }

    Timer {
        id: clearSearchText
        interval: 100
        running: false
        repeat: false
        onTriggered:
        // To be implemented by consumer
        {}
    }

    // ==========================================================================
    // Shared Signal
    // ==========================================================================

    signal appLaunched

    // ==========================================================================
    // Shared Models
    // ==========================================================================

    property alias filteredAppsModel: filteredAppsModel

    ScriptModel {
        id: filteredAppsModel
        values: {
            if (root.isCommandMode || root.activeCommandView !== "")
                return [];

            const search = root.searchText.toLowerCase();
            const category = root.selectedCategory;
            const favoriteApps = (typeof App !== 'undefined') ? App.favoriteApps : [];

            const allApps = [...DesktopEntries.applications.values].filter(app => app && app.name && app.noDisplay !== true);

            const filtered = allApps.filter(app => {
                if (category !== "") {
                    const categories = app.categories || [];
                    if (!categories.some(cat => cat.toLowerCase().includes(category.toLowerCase())))
                        return false;
                }

                if (search === "")
                    return true;

                const nameMatch = app.name.toLowerCase().includes(search);
                const commentMatch = (app.comment || "").toLowerCase().includes(search);
                const genericNameMatch = (app.genericName || "").toLowerCase().includes(search);
                const categoriesMatch = (app.categories || []).some(cat => cat.toLowerCase().includes(search));

                return nameMatch || commentMatch || genericNameMatch || categoriesMatch;
            }).sort((a, b) => {
                const aIsFavorite = favoriteApps.includes(a.name);
                const bIsFavorite = favoriteApps.includes(b.name);
                if (aIsFavorite && !bIsFavorite)
                    return -1;
                if (!aIsFavorite && bIsFavorite)
                    return 1;
                return a.name.localeCompare(b.name);
            });

            const structured = [];

            if (search === "") {
                const favorites = filtered.filter(app => favoriteApps.includes(app.name));
                if (favorites.length > 0) {
                    structured.push({ isHeader: true, letter: "Favorites", isFavoritesHeader: true });
                    favorites.forEach(app => {
                        structured.push({ isHeader: false, appData: app });
                    });
                }
            }

            let currentLetter = "";
            for (const app of filtered) {
                if (search === "" && favoriteApps.includes(app.name)) continue;

                const firstLetter = app.name.charAt(0).toUpperCase();
                if (firstLetter !== currentLetter) {
                    currentLetter = firstLetter;
                    structured.push({ isHeader: true, letter: currentLetter });
                }
                structured.push({ isHeader: false, appData: app });
            }

            return structured;
        }
    }
}

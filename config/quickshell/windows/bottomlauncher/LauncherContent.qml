// windows/bottomlauncher/LauncherContent.qml
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

    signal appLaunched
    signal gainFocus

    onGainFocus: baseLauncher.doGainFocus()

    // --- Base Launcher Instance ---
    BaseLauncher {
        id: baseLauncher

        // Properties are now managed centrally in BaseLauncher via searchText
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
                    root.appLaunched();
                } else if (cmd.action === "nextWallpaper") {
                    ThemeManager.switchToNextWallpaper();
                    root.appLaunched();
                } else if (cmd.action === "previousWallpaper") {
                    ThemeManager.switchToPreviousWallpaper();
                    root.appLaunched();
                }
            } else if (cmd.view !== "") {
                activeCommandView = cmd.view;
            }
        }

        function launchApp(command, workingDirectory) {
            clearSearchText.start();
            Quickshell.execDetached({
                command: command,
                workingDirectory: workingDirectory
            });
            root.appLaunched();
        }

        function ensureAppSelection() {
            if (baseLauncher.isCommandMode || baseLauncher.activeCommandView !== "") {
                baseLauncher.selectedAppIndex = -1;
                return;
            }
            if (baseLauncher.filteredAppsModel.values.length === 0) {
                baseLauncher.selectedAppIndex = -1;
                return;
            }
            if (baseLauncher.selectedAppIndex < 0 || baseLauncher.selectedAppIndex >= baseLauncher.filteredAppsModel.values.length) {
                baseLauncher.selectedAppIndex = 0;
            }
            appListView.currentIndex = baseLauncher.selectedAppIndex;
        }

        function ensureCommandSelection() {
            if (!baseLauncher.isCommandMode) {
                baseLauncher.selectedCommandIndex = -1;
                return;
            }
            if (baseLauncher.filteredCommands.length === 0) {
                baseLauncher.selectedCommandIndex = -1;
                return;
            }
            if (baseLauncher.selectedCommandIndex < 0 || baseLauncher.selectedCommandIndex >= baseLauncher.filteredCommands.length) {
                baseLauncher.selectedCommandIndex = 0;
            }
            commandListView.currentIndex = baseLauncher.selectedCommandIndex;
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
            searchField.text = "";
            baseLauncher.searchText = "";
            baseLauncher.activeCommandView = "";
            categoryFilter.selectedCategory = "";
            baseLauncher.selectedAppIndex = -1;
            baseLauncher.selectedCommandIndex = -1;
        }

        function doGainFocus() {
            forceActiveFocus();
            focusTimer.start();
        }

        // Override timers with specific implementations
        Timer {
            id: focusTimer
            interval: 10
            repeat: false
            onTriggered: searchField.forceActiveFocus()
        }

        Timer {
            id: clearSearchText
            interval: 100
            repeat: false
            onTriggered: {
                searchField.text = "";
                baseLauncher.searchText = "";
                categoryFilter.selectedCategory = "";
                baseLauncher.activeCommandView = "";
            }
        }
    }

    // ==========================================================================
    // UI Structure (unchanged from original)
    // ==========================================================================

    // 1. Search Bar
    RowLayout {
        id: searchRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        spacing: 8
        z: 10

        EditableField {
            id: searchField
            Layout.fillWidth: true
            Layout.fillHeight: true

            placeholderText: "Search apps... or use > for commands"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft

            normalBackground: ThemeManager.selectedTheme.colors.leftMenuBgColorV2
            normalForeground: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            focusedBorderColor: ThemeManager.selectedTheme.colors.primary
            borderColor: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
            borderSize: 1

            topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
            topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
            bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
            bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius

            onAccepted: {
                baseLauncher.activateSelection();
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) {
                    baseLauncher.moveSelection(1);
                    searchField.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_Up) {
                    baseLauncher.moveSelection(-1);
                    searchField.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    baseLauncher.activateSelection();
                    searchField.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
            }

            onTextChanged: {
                // Source of truth is updated here
                baseLauncher.searchText = searchField.text;
                Qt.callLater(baseLauncher.ensureCommandSelection);
                Qt.callLater(baseLauncher.ensureAppSelection);
            }
        }
    }

    // 2. Animated Content Area
    SwipeView {
        id: contentStack
        anchors.top: searchRow.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        currentIndex: baseLauncher.currentViewIndex
        interactive: false
        clip: true
        orientation: Qt.Horizontal

        // Page 0: Apps List & Categories
        Item {
            CategoryFilter {
                id: categoryFilter
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32
            }
            Connections {
                target: categoryFilter
                function onSelectedCategoryChanged() {
                    Qt.callLater(baseLauncher.ensureAppSelection);
                }
            }

            ScrollView {
                id: appScrollView
                anchors.top: categoryFilter.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                clip: true

                ListView {
                    id: appListView
                    width: parent.width

                    model: baseLauncher.filteredAppsModel.values
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds

                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    displayMarginBeginning: 40
                    displayMarginEnd: 40

                    delegate: Item {
                        id: delegateRoot
                        width: appListView.width
                        visible: modelData !== null
                        height: modelData && modelData.isHeader ? 30 : 70

                        opacity: 0
                        transform: Translate {
                            id: itemTrans
                            y: 15
                        }

                        Component.onCompleted: {
                            entranceAnim.start();
                        }

                        ParallelAnimation {
                            id: entranceAnim

                            SequentialAnimation {
                                PauseAnimation {
                                    duration: Math.min(appListView.index, 10) * 20
                                }

                                ParallelAnimation {
                                    NumberAnimation {
                                        target: delegateRoot
                                        property: "opacity"
                                        to: 1
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        target: itemTrans
                                        property: "y"
                                        to: 0
                                        duration: 250
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 0.8
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: modelData && modelData.isFavoritesHeader ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : ThemeManager.selectedTheme.colors.primary.alpha(0.1)
                            visible: modelData && modelData.isHeader
                            radius: ThemeManager.selectedTheme.dimensions.elementRadius
                            anchors.margins: 4

                            Text {
                                text: (modelData && modelData.letter) ? modelData.letter : ""
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                font.pixelSize: 14
                                font.bold: true
                                color: modelData && modelData.isFavoritesHeader ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.primary
                            }
                        }

                        LauncherAppItem {
                            anchors.fill: parent
                            visible: modelData && !modelData.isHeader
                            appData: modelData && modelData.appData
                            isSelected: modelData && !modelData.isHeader && baseLauncher.selectedAppIndex === index
                            isHighlighted: modelData && !modelData.isHeader && (baseLauncher.selectedAppIndex >= 0 ? (index === baseLauncher.selectedAppIndex) : (index === 0 && searchField.text !== ""))
                            isFavorite: (modelData && modelData.appData) ? App.favoriteApps.includes(modelData.appData.name) : false

                            onClicked: modelData && !modelData.isHeader && baseLauncher.launchApp(modelData.appData.command, modelData.appData.workingDirectory)
                            onFavoriteToggled: {
                                if (!modelData || modelData.isHeader) return;
                                baseLauncher.toggleFavorite(modelData.appData);
                                this.isFavorite = App.favoriteApps.includes(modelData.appData.name);
                            }
                            onHovered: modelData && !modelData.isHeader && (baseLauncher.selectedAppIndex = index)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: baseLauncher.filteredAppsModel.values.length === 0
                    text: "No applications found"
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.subtleText
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Page 1: Command List
        Item {
            ListView {
                id: commandListView
                anchors.fill: parent
                model: baseLauncher.filteredCommands
                clip: true
                spacing: 4

                delegate: CommandItem {
                    id: cmdDelegate
                    width: commandListView.width
                    commandData: modelData
                    isHighlighted: index === (baseLauncher.selectedCommandIndex >= 0 ? baseLauncher.selectedCommandIndex : 0)
                    onClicked: baseLauncher.executeCommand(modelData)

                    opacity: 0
                    transform: Translate {
                        id: cmdTrans
                        x: -10
                    }

                    Component.onCompleted: cmdAnim.start()

                    ParallelAnimation {
                        id: cmdAnim
                        NumberAnimation {
                            target: cmdDelegate
                            property: "opacity"
                            to: 1
                            duration: 150
                        }
                        NumberAnimation {
                            target: cmdTrans
                            property: "x"
                            to: 0
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: baseLauncher.filteredCommands.length === 0
                    text: "No commands found"
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.subtleText
                }
            }
        }

        // Page 2: Wallpaper Selector
        Item {
            WallpaperSelector {
                id: wallpaperSelector
                anchors.fill: parent
                onWallpaperSelected: path => {
                    baseLauncher.activeCommandView = "";
                    searchField.text = "";
                    baseLauncher.searchText = "";
                    searchField.forceActiveFocus();
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                }
                onCloseRequested: {
                    baseLauncher.activeCommandView = "";
                    searchField.text = "";
                    baseLauncher.searchText = "";
                    searchField.forceActiveFocus();
                }
            }
        }
    }

    // ==========================================================================
    // Keyboard Handling
    // ==========================================================================

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
                searchField.text = "";
                baseLauncher.searchText = "";
                searchField.forceActiveFocus();
                event.accepted = true;
                return;
            }
            baseLauncher.appLaunched();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Down) {
            baseLauncher.moveSelection(1);
            searchField.forceActiveFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Up) {
            baseLauncher.moveSelection(-1);
            searchField.forceActiveFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            baseLauncher.activateSelection();
            searchField.forceActiveFocus();
            event.accepted = true;
            return;
        }

        if (event.text && !searchField.activeFocus) {
            searchField.text += event.text;
            baseLauncher.searchText = searchField.text;
            baseLauncher.focusTimer.start();
            event.accepted = true;
        }
    }

    // ==========================================================================
    // Connections and State Management
    // ==========================================================================

    Connections {
        target: baseLauncher
        onIsCommandModeChanged: {
            if (!baseLauncher.isCommandMode && baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
            }
            baseLauncher.ensureCommandSelection();
            baseLauncher.ensureAppSelection();
        }
    }

    onVisibleChanged: {
        if (!visible)
            baseLauncher.resetState();
    }

    // Forward the appLaunched signal from baseLauncher
    Connections {
        target: baseLauncher
        onAppLaunched: root.appLaunched()
    }
}
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

    // --- Logic & Properties ---

    property bool isCommandMode: CommandsRegistry.isCommandMode(searchField.text)
    property string commandText: CommandsRegistry.getCommandText(searchField.text)
    property var filteredCommands: isCommandMode ? CommandsRegistry.filterCommands(commandText) : []
    property string activeCommandView: ""
    property int selectedAppIndex: -1
    property int selectedCommandIndex: -1

    property int currentViewIndex: {
        if (activeCommandView === "wallpaper")
            return 2;
        if (isCommandMode)
            return 1;
        return 0;
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
            root.activeCommandView = cmd.view;
        }
    }

    onIsCommandModeChanged: {
        if (!isCommandMode && activeCommandView !== "") {
            activeCommandView = "";
        }
        ensureCommandSelection();
        ensureAppSelection();
    }

    function gainFocus() {
        forceActiveFocus();
        focusTimer.start();
    }

    function exitCommandView() {
        activeCommandView = "";
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    function resetState() {
        searchField.text = "";
        activeCommandView = "";
        categoryFilter.selectedCategory = "";
        selectedAppIndex = -1;
        selectedCommandIndex = -1;
    }

    onVisibleChanged: {
        if (!visible)
            resetState();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (activeCommandView !== "") {
                exitCommandView();
                event.accepted = true;
                return;
            }
            appLaunched();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Down) {
            moveSelection(1);
            searchField.forceActiveFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Up) {
            moveSelection(-1);
            searchField.forceActiveFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activateSelection();
            searchField.forceActiveFocus();
            event.accepted = true;
            return;
        }

        if (event.text && !searchField.activeFocus) {
            searchField.text += event.text;
            focusTimer.start();
            event.accepted = true;
        }
    }

    Timer {
        id: focusTimer
        interval: 10
        onTriggered: searchField.forceActiveFocus()
    }

    Timer {
        id: clearSearchText
        interval: 100
        repeat: false
        onTriggered: {
            searchField.text = "";
            categoryFilter.selectedCategory = "";
            root.activeCommandView = "";
        }
    }

    ScriptModel {
        id: filteredModel
        values: {
            if (root.isCommandMode || root.activeCommandView !== "")
                return [];

            const searchText = searchField.text.toLowerCase();
            const category = categoryFilter.selectedCategory;

            return [...DesktopEntries.applications.values].filter(app => app && app.name && app.noDisplay !== true).filter(app => {
                if (category !== "") {
                    const categories = app.categories || [];
                    if (!categories.some(cat => cat.toLowerCase().includes(category.toLowerCase())))
                        return false;
                }

                if (searchText === "")
                    return true;

                const nameMatch = app.name.toLowerCase().includes(searchText);
                const commentMatch = (app.comment || "").toLowerCase().includes(searchText);
                const genericNameMatch = (app.genericName || "").toLowerCase().includes(searchText);
                const categoriesMatch = (app.categories || []).some(cat => cat.toLowerCase().includes(searchText));

                return nameMatch || commentMatch || genericNameMatch || categoriesMatch;
            }).sort((a, b) => a.name.localeCompare(b.name));
        }
    }

    // --- UI Structure ---

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
                activateSelection();
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) {
                    root.moveSelection(1);
                    searchField.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_Up) {
                    root.moveSelection(-1);
                    searchField.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.activateSelection();
                    searchField.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
            }

            onTextChanged: {
                Qt.callLater(root.ensureCommandSelection);
                Qt.callLater(root.ensureAppSelection);
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

        currentIndex: root.currentViewIndex
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
                    Qt.callLater(root.ensureAppSelection);
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

                    model: filteredModel
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

                    delegate: LauncherAppItem {
                        id: delegateRoot
                        width: appListView.width
                        appData: modelData
                        isSelected: root.selectedAppIndex === index
                        isHighlighted: root.selectedAppIndex >= 0 ? (index === root.selectedAppIndex) : (index === 0 && searchField.text !== "")

                        onClicked: root.launchApp(modelData.command, modelData.workingDirectory)
                        onHovered: root.selectedAppIndex = index

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
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: filteredModel.values.length === 0
                text: "No applications found"
                font.pixelSize: 14
                color: ThemeManager.selectedTheme.colors.subtleText
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Page 1: Command List
        Item {
            ListView {
                id: commandListView
                anchors.fill: parent
                model: root.filteredCommands
                clip: true
                spacing: 4

                delegate: CommandItem {
                    id: cmdDelegate
                    width: commandListView.width
                    commandData: modelData
                    isHighlighted: index === (root.selectedCommandIndex >= 0 ? root.selectedCommandIndex : 0)
                    onClicked: root.executeCommand(modelData)

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
                    visible: root.filteredCommands.length === 0
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
                    root.exitCommandView();
                    root.appLaunched();
                }
                onCloseRequested: root.exitCommandView()
            }
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
        if (root.isCommandMode || root.activeCommandView !== "") {
            selectedAppIndex = -1;
            return;
        }
        if (filteredModel.values.length === 0) {
            selectedAppIndex = -1;
            return;
        }
        if (selectedAppIndex < 0 || selectedAppIndex >= filteredModel.values.length) {
            selectedAppIndex = 0;
        }
        appListView.currentIndex = selectedAppIndex;
    }

    function ensureCommandSelection() {
        if (!root.isCommandMode) {
            selectedCommandIndex = -1;
            return;
        }
        if (root.filteredCommands.length === 0) {
            selectedCommandIndex = -1;
            return;
        }
        if (selectedCommandIndex < 0 || selectedCommandIndex >= root.filteredCommands.length) {
            selectedCommandIndex = 0;
        }
        commandListView.currentIndex = selectedCommandIndex;
    }

    function moveSelection(dir) {
        if (root.isCommandMode) {
            moveCommandSelection(dir);
            return;
        }
        if (root.activeCommandView !== "")
            return;
        if (filteredModel.values.length === 0)
            return;
        let idx = selectedAppIndex;
        if (idx < 0)
            idx = dir > 0 ? 0 : filteredModel.values.length - 1;
        else
            idx = Math.max(0, Math.min(filteredModel.values.length - 1, idx + dir));
        selectedAppIndex = idx;
    }

    function moveCommandSelection(dir) {
        if (root.filteredCommands.length === 0)
            return;
        let idx = selectedCommandIndex;
        if (idx < 0)
            idx = dir > 0 ? 0 : root.filteredCommands.length - 1;
        else
            idx = Math.max(0, Math.min(root.filteredCommands.length - 1, idx + dir));
        selectedCommandIndex = idx;
    }

    function firstEnabledCommandIndex(startIdx) {
        if (root.filteredCommands.length === 0)
            return -1;
        let idx = Math.max(0, Math.min(root.filteredCommands.length - 1, startIdx));
        for (let i = idx; i < root.filteredCommands.length; i++) {
            if (root.filteredCommands[i].enabled !== false)
                return i;
        }
        for (let i = idx - 1; i >= 0; i--) {
            if (root.filteredCommands[i].enabled !== false)
                return i;
        }
        return -1;
    }

    function activateSelection() {
        if (root.isCommandMode) {
            activateCommandSelection();
            return;
        }
        if (root.activeCommandView !== "")
            return;
        let idx = selectedAppIndex;
        if (idx < 0)
            idx = 0;
        if (idx < 0 || idx >= filteredModel.values.length)
            return;
        const app = filteredModel.values[idx];
        if (!app)
            return;
        root.launchApp(app.command, app.workingDirectory);
    }

    function activateCommandSelection() {
        if (root.filteredCommands.length === 0)
            return;
        let idx = selectedCommandIndex >= 0 ? selectedCommandIndex : 0;
        idx = firstEnabledCommandIndex(idx);
        if (idx === -1)
            return;
        root.executeCommand(root.filteredCommands[idx]);
    }

    onSelectedAppIndexChanged: {
        if (selectedAppIndex >= 0) {
            appListView.currentIndex = selectedAppIndex;
            appListView.positionViewAtIndex(selectedAppIndex, ListView.Contain);
        } else {
            appListView.currentIndex = -1;
        }
    }

    onSelectedCommandIndexChanged: {
        if (selectedCommandIndex >= 0) {
            commandListView.currentIndex = selectedCommandIndex;
            commandListView.positionViewAtIndex(selectedCommandIndex, ListView.Contain);
        } else {
            commandListView.currentIndex = -1;
        }
    }
}

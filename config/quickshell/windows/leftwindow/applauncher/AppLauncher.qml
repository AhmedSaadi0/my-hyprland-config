import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "./AppItem.qml"
import "root:/config"
import "root:/config/EventNames.js" as Events

import "root:/windows/bottomlauncher"

ColumnLayout {
    id: root
    width: parent.width
    height: parent.height
    spacing: 0
    focus: true
    readonly property int sidePadding: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

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
                EventBus.emit(Events.CLOSE_LEFTBAR);
            } else if (cmd.action === "nextWallpaper") {
                ThemeManager.switchToNextWallpaper();
                EventBus.emit(Events.CLOSE_LEFTBAR);
            } else if (cmd.action === "previousWallpaper") {
                ThemeManager.switchToPreviousWallpaper();
                EventBus.emit(Events.CLOSE_LEFTBAR);
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
        if (categoryFilter)
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
            searchField.append(event.text);
            focusTimer.start();
            event.accepted = true;
        }
    }

    // --- UI Elements ---
    TopAppBar {
        Layout.fillWidth: true
        title: qsTr("Apps")
        icon: "󰀻"
        // scrollY: 0
        // primaryActionVisible: false
    }

    EditableField {
        id: searchField
        Layout.fillWidth: true
        Layout.leftMargin: root.sidePadding
        Layout.rightMargin: root.sidePadding
        Layout.topMargin: ThemeManager.selectedTheme.dimensions.spacingMedium
        Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.spacingMedium
        placeholderText: "Search apps... or use > for commands"
        font.pixelSize: 16

        normalBackground: ThemeManager.selectedTheme.colors.leftMenuBgColorV1
        normalForeground: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
        focusedBorderColor: ThemeManager.selectedTheme.colors.primary

        borderColor: ThemeManager.selectedTheme.colors.primary
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

        function append(text) {
            searchField.text += text;
        }
    }

    // --- Main Content Area ---

    SwipeView {
        id: viewStack
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: root.sidePadding
        Layout.rightMargin: root.sidePadding
        currentIndex: root.currentViewIndex
        interactive: false
        clip: true
        orientation: Qt.Horizontal

        // Page 0: App List + Category Filter
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
                anchors.top: categoryFilter.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ListView {
                    id: listView
                    anchors.fill: parent
                    model: processedModel
                    clip: true
                    spacing: 0

                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    delegate: Item {
                        id: delegateRoot
                        width: listView.width
                        height: modelData.isHeader ? 40 : 70

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
                                    duration: Math.min(commandListView.index, 10) * 20
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
                            color: ThemeManager.selectedTheme.colors.primary.alpha(0.15)
                            visible: modelData.isHeader
                            radius: ThemeManager.selectedTheme.dimensions.elementRadius

                            Text {
                                text: modelData.letter !== undefined ? modelData.letter : ""
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                font.pixelSize: 18
                                font.bold: true
                                color: ThemeManager.selectedTheme.colors.topbarFgColor
                            }
                        }

                        AppItem {
                            anchors.fill: parent
                            visible: !modelData.isHeader
                            desktopEntity: modelData.appData
                            isSelected: root.selectedAppIndex === index
                            onItemClicked: {
                                root.selectedAppIndex = index;
                                root.launchSelectedApp(modelData.appData.command, modelData.appData.workingDirectory);
                            }
                        }
                    }
                }
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
                // active: SwipeView.isCurrentItem

                onWallpaperSelected: path => {
                    root.exitCommandView();
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                }

                onCloseRequested: {
                    root.exitCommandView();
                }
            }
        }
    }

    // --- Timers & Models ---

    Timer {
        id: clearSearchText
        interval: 100
        repeat: false
        onTriggered: {
            searchField.text = "";
            if (categoryFilter)
                categoryFilter.selectedCategory = "";
            root.activeCommandView = "";
        }
    }

    Timer {
        id: focusTimer
        interval: 10
        onTriggered: searchField.forceActiveFocus()
    }

    ScriptModel {
        id: processedModel

        values: {
            if (root.isCommandMode || root.activeCommandView !== "")
                return [];

            const searchText = searchField.text.toLowerCase();
            const selectedCat = categoryFilter ? categoryFilter.selectedCategory : "";

            const sortedApps = [...DesktopEntries.applications.values].filter(app => app && app.name && app.noDisplay !== true).sort((a, b) => a.name.localeCompare(b.name)).filter(app => {
                if (selectedCat !== "") {
                    const appCats = app.categories || [];
                    const hasCat = appCats.some(c => c.toLowerCase().includes(selectedCat.toLowerCase()));
                    if (!hasCat)
                        return false;
                }

                if (searchText === "")
                    return true;

                const nameMatch = app.name.toLowerCase().includes(searchText);
                const commentMatch = (app.comment || "").toLowerCase().includes(searchText);
                const genericNameMatch = (app.genericName || "").toLowerCase().includes(searchText);
                const categoriesMatch = (app.categories || []).some(category => category.toLowerCase().includes(searchText));

                return nameMatch || commentMatch || genericNameMatch || categoriesMatch;
            });

            let finalList = [];
            let currentLetter = "";

            for (let i = 0; i < sortedApps.length; i++) {
                const app = sortedApps[i];
                const firstLetter = app.name.charAt(0).toUpperCase();

                if (firstLetter !== currentLetter) {
                    currentLetter = firstLetter;
                    finalList.push({
                        isHeader: true,
                        letter: currentLetter
                    });
                }

                finalList.push({
                    isHeader: false,
                    appData: app
                });
            }

            // console.info("sortedApps finalList -> " + JSON.stringify(finalList));

            return finalList;
        }
    }

    function launchSelectedApp(command, workingDirectory) {
        clearSearchText.stop();
        Quickshell.execDetached({
            command: command,
            workingDirectory: workingDirectory
        });
        clearSearchText.start();
        EventBus.emit(Events.CLOSE_LEFTBAR);
    }

    function isSelectableAppIndex(idx) {
        return idx >= 0 && idx < processedModel.values.length && processedModel.values[idx] && !processedModel.values[idx].isHeader;
    }

    function firstSelectableAppIndex() {
        for (let i = 0; i < processedModel.values.length; i++) {
            if (isSelectableAppIndex(i))
                return i;
        }
        return -1;
    }

    function lastSelectableAppIndex() {
        for (let i = processedModel.values.length - 1; i >= 0; i--) {
            if (isSelectableAppIndex(i))
                return i;
        }
        return -1;
    }

    function nextSelectableAppIndex(start, dir) {
        let i = start + dir;
        while (i >= 0 && i < processedModel.values.length) {
            if (isSelectableAppIndex(i))
                return i;
            i += dir;
        }
        return -1;
    }

    function ensureAppSelection() {
        if (root.isCommandMode || root.activeCommandView !== "") {
            selectedAppIndex = -1;
            return;
        }
        if (!isSelectableAppIndex(selectedAppIndex)) {
            selectedAppIndex = firstSelectableAppIndex();
        }
        listView.currentIndex = selectedAppIndex;
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
        let idx = selectedAppIndex;
        if (idx < 0)
            idx = dir > 0 ? firstSelectableAppIndex() : lastSelectableAppIndex();
        else
            idx = nextSelectableAppIndex(idx, dir);
        if (idx !== -1)
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
            idx = firstSelectableAppIndex();
        if (idx === -1)
            return;
        const item = processedModel.values[idx];
        if (!item || item.isHeader)
            return;
        root.launchSelectedApp(item.appData.command, item.appData.workingDirectory);
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
            listView.currentIndex = selectedAppIndex;
            listView.positionViewAtIndex(selectedAppIndex, ListView.Contain);
        } else {
            listView.currentIndex = -1;
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

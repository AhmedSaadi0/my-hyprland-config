import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "./AppItem.qml"
import "root:/config"
import "root:/config/EventNames.js" as Events

ColumnLayout {
    id: root
    width: parent.width
    height: parent.height
    // anchors.fill: parent
    spacing: 0
    focus: true

    // Command mode using shared registry
    property bool isCommandMode: CommandsRegistry.isCommandMode(searchField.text)
    property string commandText: CommandsRegistry.getCommandText(searchField.text)
    property var filteredCommands: isCommandMode ? CommandsRegistry.filterCommands(commandText) : []

    function executeCommand(cmd) {
        if (cmd.isAction) {
            // Handle action commands
            if (cmd.action === "openSettings") {
                EventBus.emit(Events.OPEN_SETTINGS);
                EventBus.emit(Events.CLOSE_LEFTBAR);
            }
        } else if (cmd.view !== "") {
            // Show the command view
            root.activeCommandView = cmd.view;
        }
    }

    // Current command view (empty = none, "wallpaper" = wallpaper selector, etc.)
    property string activeCommandView: ""

    // Auto-close command view when exiting command mode
    onIsCommandModeChanged: {
        if (!isCommandMode && activeCommandView !== "") {
            activeCommandView = "";
        }
    }

    function gainFocus() {
        forceActiveFocus();
        focusTimer.start();
    // searchField.forceActiveFocus();
    }

    function exitCommandView() {
        activeCommandView = "";
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    function resetState() {
        searchField.text = "";
        activeCommandView = "";
    }

    // Reset when parent becomes invisible
    onVisibleChanged: {
        if (!visible) {
            resetState();
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (activeCommandView !== "") {
                exitCommandView();
                event.accepted = true;
                return;
            }
        }

        if (event.text && !searchField.activeFocus) {
            searchField.append(event.text);
            // searchField.forceActiveFocus();
            focusTimer.start();
            event.accepted = true;
        }
    }

    EditableField {
        id: searchField
        Layout.fillWidth: true
        // Layout.margins: 12
        Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
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

        // horizontalAlignment: Text.HAlignment
        // verticalAlignment: Text.VAlignment

        onAccepted: {
            // Handle command mode
            if (root.isCommandMode && root.filteredCommands.length > 0) {
                const cmd = root.filteredCommands[0];
                root.executeCommand(cmd);
                return;
            }

            if (processedModel.values.length > 1) {
                const firstAppItem = processedModel.values[1];
                root.launchSelectedApp(firstAppItem.appData.command, firstAppItem.appData.workingDirectory);
            }
        }

        function append(text) {
            searchField.text += text;
        }
    }

    Timer {
        id: clearSearchText
        interval: 100
        repeat: false
        onTriggered: {
            searchField.text = "";
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
            const searchText = searchField.text.toLowerCase();
            const sortedApps = [...DesktopEntries.applications.values].filter(app => app && app.name && app.noDisplay !== true).sort((a, b) => a.name.localeCompare(b.name)).filter(app => {
                if (searchText === "")
                    return true;

                const nameMatch = app.name.toLowerCase().includes(searchText);
                const commentMatch = (app.comment || "").toLowerCase().includes(searchText);
                const genericNameMatch = (app.genericName || "").toLowerCase().includes(searchText);

                // جديد: البحث في الفئات
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

            return finalList;
        }
    }

    // Command suggestions list (shows when typing commands with >)
    ListView {
        id: commandListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.isCommandMode && root.activeCommandView === ""

        model: root.filteredCommands
        clip: true
        spacing: 4

        delegate: CommandItem {
            width: commandListView.width
            commandData: modelData
            isHighlighted: index === 0
            onClicked: root.executeCommand(modelData)
        }

        Text {
            anchors.centerIn: parent
            visible: root.filteredCommands.length === 0
            text: "No commands found"
            font.pixelSize: 14
            color: ThemeManager.selectedTheme.colors.subtleText
        }
    }

    // Wallpaper Selector View
    WallpaperSelector {
        id: wallpaperSelector
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.activeCommandView === "wallpaper"

        onWallpaperSelected: path => {
            root.exitCommandView();
            EventBus.emit(Events.CLOSE_LEFTBAR);
        }

        onCloseRequested: {
            root.exitCommandView();
        }
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        visible: !root.isCommandMode && root.activeCommandView === ""

        ListView {
            id: listView
            anchors.fill: parent
            model: processedModel
            clip: true
            spacing: 0

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            add: Transition {
                ParallelAnimation {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1.0
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }
            }

            remove: Transition {
                ParallelAnimation {
                    PropertyAnimation {
                        property: "opacity"
                        to: 0
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                    PropertyAnimation {
                        property: "scale"
                        to: 0.85
                        duration: 200
                        easing.type: Easing.InCubic
                    }
                }
            }

            delegate: Item {
                id: delegateRoot
                width: listView.width
                height: modelData.isHeader ? 40 : 70
                opacity: 1.0
                scale: 1.0
                transformOrigin: Item.Center

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

                    onItemClicked: {
                        root.launchSelectedApp(modelData.appData.command, modelData.appData.workingDirectory);
                    }
                }
            }
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
}

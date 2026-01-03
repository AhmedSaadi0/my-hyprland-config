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

    // Command mode using shared registry
    property bool isCommandMode: CommandsRegistry.isCommandMode(searchField.text)
    property string commandText: CommandsRegistry.getCommandText(searchField.text)
    property var filteredCommands: isCommandMode ? CommandsRegistry.filterCommands(commandText) : []

    function executeCommand(cmd) {
        if (cmd.isAction) {
            // Handle action commands
            if (cmd.action === "openSettings") {
                EventBus.emit(Events.OPEN_SETTINGS);
                root.appLaunched();
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
            appLaunched();
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
            const searchText = searchField.text.toLowerCase();
            const category = categoryFilter.selectedCategory;

            return [...DesktopEntries.applications.values]
                .filter(app => app && app.name && app.noDisplay !== true)
                .filter(app => {
                    if (category !== "") {
                        const categories = app.categories || [];
                        const categoryMatch = categories.some(cat => 
                            cat.toLowerCase().includes(category.toLowerCase())
                        );
                        if (!categoryMatch) return false;
                    }

                    if (searchText === "") return true;

                    const nameMatch = app.name.toLowerCase().includes(searchText);
                    const commentMatch = (app.comment || "").toLowerCase().includes(searchText);
                    const genericNameMatch = (app.genericName || "").toLowerCase().includes(searchText);
                    const categoriesMatch = (app.categories || []).some(cat => 
                        cat.toLowerCase().includes(searchText)
                    );

                    return nameMatch || commentMatch || genericNameMatch || categoriesMatch;
                })
                .sort((a, b) => a.name.localeCompare(b.name));
        }
    }

    // Search Bar
    RowLayout {
        id: searchRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        spacing: 8

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
                // Handle command mode
                if (root.isCommandMode && root.filteredCommands.length > 0) {
                    const cmd = root.filteredCommands[0];
                    root.executeCommand(cmd);
                    return;
                }

                if (filteredModel.values.length > 0) {
                    const firstApp = filteredModel.values[0];
                    root.launchApp(firstApp.command, firstApp.workingDirectory);
                }
            }
        }

       
    }

    // Category Filter
    CategoryFilter {
        id: categoryFilter
        anchors.top: searchRow.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32
        visible: !root.isCommandMode && root.activeCommandView === ""
    }

    // Command suggestions list (shows when typing commands with >)
    ListView {
        id: commandListView
        anchors.top: searchRow.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
        anchors.top: searchRow.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: root.activeCommandView === "wallpaper"

        onWallpaperSelected: path => {
            root.exitCommandView();
            root.appLaunched();
        }

        onCloseRequested: {
            root.exitCommandView();
        }
    }

    // App List
    ListView {
        id: appListView
        anchors.top: categoryFilter.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: scrollBarBg.left
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        visible: !root.isCommandMode && root.activeCommandView === ""

        model: filteredModel
        clip: true
        spacing: 2
        currentIndex: -1
        boundsBehavior: Flickable.StopAtBounds

        delegate: LauncherAppItem {
            width: appListView.width
            appData: modelData
            isSelected: appListView.currentIndex === index
            isHighlighted: index === 0 && searchField.text !== ""

            onClicked: {
                root.launchApp(modelData.command, modelData.workingDirectory);
            }

            onHovered: {
                appListView.currentIndex = index;
            }
        }

        Text {
            anchors.centerIn: parent
            visible: filteredModel.values.length === 0
            text: "No applications found"
            font.pixelSize: 14
            color: ThemeManager.selectedTheme.colors.subtleText
        }
    }

    // Scrollbar
    Rectangle {
        id: scrollBarBg
        anchors.right: parent.right
        anchors.top: categoryFilter.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        width: 6
        visible: appListView.visible && appListView.contentHeight > appListView.height
        radius: 3
        color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2

        Rectangle {
            id: scrollHandle
            anchors.horizontalCenter: parent.horizontalCenter
            width: 6
            radius: 3
            color: handleMouseArea.containsMouse || handleMouseArea.pressed
                ? ThemeManager.selectedTheme.colors.primary
                : ThemeManager.selectedTheme.colors.primary.alpha(0.6)

            y: Math.max(0, Math.min(parent.height - height, appListView.visibleArea.yPosition * parent.height))
            height: Math.max(30, appListView.visibleArea.heightRatio * parent.height)

            MouseArea {
                id: handleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                drag.target: parent
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollBarBg.height - scrollHandle.height

                onPositionChanged: {
                    if (drag.active) {
                        let ratio = scrollHandle.y / (scrollBarBg.height - scrollHandle.height);
                        appListView.contentY = ratio * (appListView.contentHeight - appListView.height);
                    }
                }
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
}

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

    // --- Logic & Properties ---

    property bool isCommandMode: CommandsRegistry.isCommandMode(searchField.text)
    property string commandText: CommandsRegistry.getCommandText(searchField.text)
    property var filteredCommands: isCommandMode ? CommandsRegistry.filterCommands(commandText) : []
    property string activeCommandView: ""

    property int currentViewIndex: {
        if (activeCommandView === "wallpaper")
            return 2;
        if (isCommandMode)
            return 1;
        return 0;
    }

    function executeCommand(cmd) {
        if (cmd.isAction) {
            if (cmd.action === "openSettings") {
                EventBus.emit(Events.OPEN_SETTINGS);
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

        if (event.text && !searchField.activeFocus) {
            searchField.append(event.text);
            focusTimer.start();
            event.accepted = true;
        }
    }

    // --- UI Elements ---

    EditableField {
        id: searchField
        Layout.fillWidth: true
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

        onAccepted: {
            if (root.isCommandMode && root.filteredCommands.length > 0) {
                const cmd = root.filteredCommands[0];
                root.executeCommand(cmd);
                return;
            }
            if (processedModel.values.length > 1) {
                const firstAppItem = processedModel.values.find(item => !item.isHeader);
                if (firstAppItem) {
                    root.launchSelectedApp(firstAppItem.appData.command, firstAppItem.appData.workingDirectory);
                }
            }
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
                            onItemClicked: {
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
                    isHighlighted: index === 0
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
}

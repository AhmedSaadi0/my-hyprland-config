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

    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property var dims: ThemeManager.selectedTheme.dimensions

    BaseLauncher {
        id: baseLauncher

        selectedCategory: categoryFilter.selectedCategory

        onAppLaunchedCallback: function () {
            EventBus.emit(Events.CLOSE_LEFTBAR);
        }
        onCommandExecutedCallback: function (cmd) {
            if (cmd.isAction) {
                EventBus.emit(Events.CLOSE_LEFTBAR);
            }
        }
        onResetStateCallback: function () {
            appsHeader.searchText = "";
        }
        onRequestFocusCallback: function () {
            appsHeader.forceSearchFocus();
        }
    }

    Item {
        id: categoryFilter
        property string selectedCategory: ""
    }

    headerContent: AppsHeader {
        id: appsHeader
        width: root.width

        onSearchTextChanged: {
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

        AppsList {
            id: appsList
            baseLauncher: baseLauncher
            listModel: baseLauncher.filteredAppsModel.values
            selectedIndex: baseLauncher.selectedAppIndex

            onCategoryChanged: Qt.callLater(baseLauncher.ensureAppSelection)
            onAppClicked: (index, appData) => {
                baseLauncher.selectedAppIndex = index;
                baseLauncher.launchApp(appData.command, appData.workingDirectory);
            }
        }

        CommandsList {
            id: commandsList
            listModel: baseLauncher.filteredCommands
            selectedIndex: baseLauncher.selectedCommandIndex

            onCommandClicked: cmdData => baseLauncher.executeCommand(cmdData)
        }

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

    Keys.onPressed: event => {
        if (event.text && !appsHeader.activeFocus) {
            appsHeader.appendText(event.text);
            baseLauncher.searchText = appsHeader.searchText;
            event.accepted = true;
        }
    }

    onVisibleChanged: {
        if (!visible)
            baseLauncher.resetState();
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
}

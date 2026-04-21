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

    BaseLauncher {
        id: baseLauncher

        selectedCategory: categoryFilter.selectedCategory

        onAppLaunchedCallback: function() {
            root.appLaunched();
        }
        onCommandExecutedCallback: function() {
            root.appLaunched();
        }
        onResetStateCallback: function() {
            searchField.text = "";
            categoryFilter.selectedCategory = "";
        }
        onRequestFocusCallback: function() {
            searchField.forceActiveFocus();
        }
    }

    CategoryFilter {
        id: categoryFilter
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32

        Connections {
            target: categoryFilter
            function onSelectedCategoryChanged() {
                Qt.callLater(baseLauncher.ensureAppSelection);
            }
        }
    }

    RowLayout {
        id: searchRow
        anchors.top: categoryFilter.bottom
        anchors.topMargin: 8
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
                baseLauncher.searchText = searchField.text;
                Qt.callLater(baseLauncher.ensureCommandSelection);
                Qt.callLater(baseLauncher.ensureAppSelection);
            }
        }
    }

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

        Item {
            ScrollView {
                id: appScrollView
                anchors.fill: parent

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
                                color: ThemeManager.selectedTheme.colors.primary
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

                Connections {
                    target: baseLauncher
                    function onSelectedAppIndexChanged() {
                        if (baseLauncher.selectedAppIndex >= 0) {
                            appListView.currentIndex = baseLauncher.selectedAppIndex;
                            appListView.positionViewAtIndex(
                                baseLauncher.selectedAppIndex,
                                ListView.Contain
                            );
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

        Item {
            WallpaperSelector {
                id: wallpaperSelector
                anchors.fill: parent
                onWallpaperSelected: path => {
                    baseLauncher.activeCommandView = "";
                    searchField.text = "";
                    baseLauncher.searchText = "";
                    searchField.forceActiveFocus();
                    root.appLaunched();
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
            root.appLaunched();
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
            event.accepted = true;
        }
    }

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

    Connections {
        target: baseLauncher
        onAppLaunched: root.appLaunched()
    }
}

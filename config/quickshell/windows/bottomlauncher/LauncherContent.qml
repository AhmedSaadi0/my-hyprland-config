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

    function gainFocus() {
        forceActiveFocus();
        focusTimer.start();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
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
        radius: 3
        color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2
        visible: appListView.contentHeight > appListView.height

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

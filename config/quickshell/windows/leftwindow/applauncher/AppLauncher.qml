import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "./AppItem.qml"

ColumnLayout {
    width: parent.width
    height: parent.height
    spacing: 0

    // LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    // LayoutMirroring.childrenInherit: true

    EditableField {
        id: searchField
        Layout.fillWidth: true
        // Layout.margins: 12
        Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        placeholderText: "Search for an application..."
        font.pixelSize: 16

        normalBackground: ThemeManager.selectedTheme.colors.leftMenuBgColorV1
        normalForeground: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
        focusedBorderColor: ThemeManager.selectedTheme.colors.primary

        borderColor: ThemeManager.selectedTheme.colors.primary
        borderSize: 1

        topLeftRadius: ThemeManager.selectedTheme.dimensions.baseRadius
        topRightRadius: ThemeManager.selectedTheme.dimensions.baseRadius
        bottomLeftRadius: ThemeManager.selectedTheme.dimensions.baseRadius
        bottomRightRadius: ThemeManager.selectedTheme.dimensions.baseRadius

        horizontalAlignment: Text.HAlignment
        verticalAlignment: Text.VAlignment

        onAccepted: {
            if (processedModel.values.length > 1) {
                const firstAppItem = processedModel.values[1];

                Quickshell.execDetached({
                    command: firstAppItem.appData.command,
                    workingDirectory: firstAppItem.appData.workingDirectory
                });

                searchField.text = "";
            }
        }
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
                return nameMatch || commentMatch || genericNameMatch;
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

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: listView
            anchors.fill: parent
            model: processedModel
            clip: true

            delegate: Item {
                width: listView.width
                height: modelData.isHeader ? 40 : 70

                Rectangle {
                    anchors.fill: parent
                    color: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
                    visible: modelData.isHeader

                    Text {
                        text: modelData.letter !== undefined ? modelData.letter : ""
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        font.pixelSize: 18
                        font.bold: true
                        color: ThemeManager.selectedTheme.colors.onPrimary
                    }
                }

                AppItem {
                    anchors.fill: parent
                    visible: !modelData.isHeader
                    desktopEntity: modelData.appData

                    onItemClicked: {
                        Quickshell.execDetached({
                            command: modelData.appData.command,
                            workingDirectory: modelData.appData.workingDirectory
                        });
                        searchField.text = "";
                    }
                }
            }
        }
    }
}

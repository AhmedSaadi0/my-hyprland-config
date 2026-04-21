// windows/leftwindow/applauncher/AppsList.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/components"
import "root:/windows/bottomlauncher"
import "root:/config"

Item {
    id: rootList

    property var listModel
    property var baseLauncher
    property int selectedIndex: -1
    property alias selectedCategory: categoryFilter.selectedCategory

    signal appClicked(int index, var appData)
    signal categoryChanged

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (rootList.selectedIndex >= 0 && rootList.selectedIndex < rootList.listModel.length) {
                const item = rootList.listModel[rootList.selectedIndex];
                if (item && !item.isHeader) {
                    rootList.appClicked(rootList.selectedIndex, item.appData);
                }
            }
            event.accepted = true;
        }
    }

    CategoryFilter {
        id: categoryFilter
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32

        onSelectedCategoryChanged: {
            rootList.categoryChanged();
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
            model: rootList.listModel
            clip: true
            spacing: 0

            onCurrentIndexChanged: {
                if (currentIndex >= 0) {
                    positionViewAtIndex(currentIndex, ListView.Contain);
                }
            }

            Connections {
                target: rootList.baseLauncher
                function onSelectedAppIndexChanged() {
                    if (rootList.baseLauncher.selectedAppIndex >= 0 && listView.currentIndex !== rootList.baseLauncher.selectedAppIndex) {
                        listView.currentIndex = rootList.baseLauncher.selectedAppIndex;
                        listView.positionViewAtIndex(rootList.baseLauncher.selectedAppIndex, ListView.Contain);
                    }
                }
            }

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

                Component.onCompleted: entranceAnim.start()

                ParallelAnimation {
                    id: entranceAnim
                    SequentialAnimation {
                        PauseAnimation {
                            duration: Math.min(index, 10) * 20
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: delegateRoot
                                property: "opacity"
                                to: 1
                                duration: 200
                            }
                            NumberAnimation {
                                target: itemTrans
                                property: "y"
                                to: 0
                                duration: 250
                                easing.type: Easing.OutBack
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
                    visible: modelData && !modelData.isHeader
                    desktopEntity: modelData && modelData.appData ? modelData.appData : null
                    isSelected: modelData && !modelData.isHeader && rootList.selectedIndex === index
                    isFavorite: (modelData && modelData.appData) ? App.favoriteApps.includes(modelData.appData.name) : false

                    onItemClicked: {
                        if (modelData && modelData.appData) {
                            rootList.appClicked(index, modelData.appData);
                        }
                    }
                }
            }
        }
    }
}

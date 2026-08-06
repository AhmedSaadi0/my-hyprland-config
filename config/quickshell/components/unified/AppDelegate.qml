// components/unified/AppDelegate.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "root:/components"
import "root:/components/app_launcher"
import "root:/themes"
import "root:/config"

Item {
    id: root

    property var entryData: null
    property bool isSelected: false
    property bool isHighlighted: false
    property bool isFavorite: false
    property bool isPinnedToDock: false
    signal itemClicked
    signal favoriteToggled
    signal pinToggled
    signal hovered
    signal openWithDefaultLocale

    width: ListView.view ? ListView.view.width : (parent ? parent.width : 0)
    height: entryData && entryData.isHeader ? 34 : 72

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
                    target: root
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
        color: entryData && entryData.isFavoritesHeader ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : ThemeManager.selectedTheme.colors.primary.alpha(0.1)
        visible: entryData && entryData.isHeader
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        anchors.margins: 2

        Text {
            text: (entryData && entryData.letter) ? entryData.letter : ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            font.pixelSize: 14
            font.bold: true
            color: ThemeManager.selectedTheme.colors.primary
        }
    }

    AppItem {
        anchors.fill: parent
        visible: entryData && !entryData.isHeader
        appData: entryData && entryData.appData ? entryData.appData : null
        isSelected: root.isSelected
        isHighlighted: root.isHighlighted
        isFavorite: root.isFavorite
        isPinnedToDock: root.isPinnedToDock

        onClicked: root.itemClicked()
        onFavoriteToggled: root.favoriteToggled()
        onPinToggled: root.pinToggled()
        onHovered: root.hovered()
        onOpenWithDefaultLocale: {
            console.info("[Locale][AppDelegate] forwarding openWithDefaultLocale, entryData isHeader=" + (entryData ? entryData.isHeader : "?"));
            root.openWithDefaultLocale();
        }
    }
}

// components/wallpaper_selector/WallpaperGrid.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "root:/themes"

Rectangle {
    id: root

    property var wallpapers: []
    property bool isWallhaven: false
    property bool loading: false
    property bool compact: false
    property string currentWallpaper: ""
    property string emptyText: qsTr("No wallpapers found")

    signal wallpaperClicked(var wallpaperData)
    signal loadMore

    radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
    color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#1a1a2e"
    clip: true

    GridView {
        id: wallpaperGrid
        anchors.fill: parent
        anchors.margins: 8

        property int columns: root.compact ? 1 : 4
        cellWidth: (width - 16) / columns
        cellHeight: root.compact ? cellWidth * 0.5 + 24 : cellWidth * 0.6 + 28

        model: root.wallpapers
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

        onAtYEndChanged: {
            if (atYEnd && root.isWallhaven && !root.loading) {
                root.loadMore();
            }
        }

        delegate: WallpaperCard {
            width: wallpaperGrid.cellWidth
            height: wallpaperGrid.cellHeight
            
            isWallhaven: root.isWallhaven
            currentWallpaper: root.currentWallpaper

            onClicked: wallpaperData => root.wallpaperClicked(wallpaperData)
        }
    }

    // Empty state
    Text {
        anchors.centerIn: parent
        visible: root.wallpapers.length === 0 && !root.loading
        text: root.emptyText
        font.pixelSize: 14
        color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
        horizontalAlignment: Text.AlignHCenter
    }

    // Loading state
    Rectangle {
        anchors.centerIn: parent
        width: 48
        height: 48
        radius: 24
        color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
        visible: root.loading && root.wallpapers.length === 0

        Text {
            anchors.centerIn: parent
            text: "󰑐"
            font.pixelSize: 24
            font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
            color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"

            RotationAnimation on rotation {
                running: root.loading
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }
    }

    // Load more indicator
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 8
        width: loadMoreText.width + 24
        height: 28
        radius: 14
        color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.9) || "#6366f1"
        visible: root.isWallhaven && root.loading && root.wallpapers.length > 0

        Text {
            id: loadMoreText
            anchors.centerIn: parent
            text: "Loading more..."
            font.pixelSize: 11
            color: "#fff"
        }
    }
}

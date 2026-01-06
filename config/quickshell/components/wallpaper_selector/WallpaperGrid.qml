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

    property var downloadingList: []

    signal wallpaperDownloadAndApply(var wallpaperData)
    signal wallpaperPreview(var wallpaperData)
    signal wallpaperDownloadOnly(var wallpaperData)
    signal loadMore

    radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
    color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#1a1a2e"
    clip: true
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 8

        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        GridView {
            id: wallpaperGrid
            anchors.fill: parent
            anchors.margins: 8

            property int columns: root.compact ? 1 : 4
            cellWidth: (width - 16) / columns
            cellHeight: root.compact ? cellWidth * 0.5 + 24 : cellWidth * 0.6 + 28
            // NOTE: -> needs qt 6.10 or higher
            // delegateModelAccess: DelegateModel.ReadOnly

            model: root.wallpapers
            clip: true

            // boundsBehavior: Flickable.StopAtBounds
            // flickDeceleration: 1000
            // maximumFlickVelocity: 3000
            // ScrollBar.vertical: ScrollBar {
            //     active: true
            //     policy: ScrollBar.AsNeeded
            // }

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

                isDownloading: {
                    if (!root.isWallhaven)
                        return false;
                    return root.downloadingList.indexOf(modelData.id) !== -1;
                }

                onDownloadAndApply: wallpaperData => root.wallpaperDownloadAndApply(wallpaperData)
                onDownloadOnly: wallpaperData => root.wallpaperDownloadOnly(wallpaperData)
                onPreview: wallpaperData => root.wallpaperPreview(wallpaperData)
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: wallpaperGrid.count === 0 && !root.loading
        text: root.emptyText
        font.pixelSize: 14
        color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        anchors.centerIn: parent
        width: 48
        height: 48
        radius: 24
        color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
        visible: root.loading && wallpaperGrid.count === 0

        Text {
            anchors.centerIn: parent
            text: "󰑐"
            font.pixelSize: 24
            font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
            color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"

            RotationAnimation on rotation {
                running: root.loading && wallpaperGrid.count === 0
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        width: 120
        height: 32
        radius: 16
        color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.9) || "#6366f1"

        visible: root.isWallhaven && root.loading && wallpaperGrid.count > 0

        Row {
            anchors.centerIn: parent
            spacing: 8

            BusyIndicator {
                width: 20
                height: 20
                running: true
                contentItem: Item {
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: "transparent"
                        border.width: 2
                        border.color: "white"
                        visible: true
                    }
                }
            }

            Text {
                text: "Loading..."
                font.pixelSize: 12
                font.bold: true
                color: "#fff"
            }
        }
    }
}

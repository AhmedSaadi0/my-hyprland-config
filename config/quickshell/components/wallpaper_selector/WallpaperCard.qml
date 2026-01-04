// components/wallpaper_selector/WallpaperCard.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"

Item {
    id: root

    required property var modelData
    required property int index
    property bool isWallhaven: false
    property string currentWallpaper: ""

    property bool isDownloading: false

    signal clicked(var wallpaperData)

    property string thumbUrl: {
        if (!modelData)
            return "";
        return isWallhaven ? (modelData.thumb || "") : ("file://" + modelData);
    }

    property string wallpaperPath: {
        if (!modelData)
            return "";
        return isWallhaven ? (modelData.path || "") : modelData;
    }

    property string displayName: {
        if (!modelData)
            return "";
        if (isWallhaven) {
            return modelData.resolution || modelData.id || "";
        }
        return typeof modelData === 'string' ? modelData.split('/').pop() : "";
    }

    Rectangle {
        id: cardBg
        anchors.fill: parent
        anchors.margins: 4
        radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
        color: itemMouseArea.containsMouse ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.15) || "#333" : "transparent"
        border.color: root.currentWallpaper === root.wallpaperPath ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : itemMouseArea.containsMouse ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.5) || "#555" : "transparent"
        border.width: root.currentWallpaper === root.wallpaperPath ? 2 : 1

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: (ThemeManager.selectedTheme?.dimensions?.elementRadius || 8) - 2
                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#111"
                clip: true

                Image {
                    id: thumbImage
                    anchors.fill: parent
                    source: root.thumbUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize: Qt.size(300, 200)
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                    visible: thumbImage.status === Image.Loading

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.pixelSize: 14
                        font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                        color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"

                        RotationAnimation on rotation {
                            running: thumbImage.status === Image.Loading
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }

                // Wallhaven badge
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 4
                    height: 16
                    width: favText.width + 8
                    radius: 4
                    color: "#000000aa"
                    visible: root.isWallhaven && root.modelData && (root.modelData.favorites || 0) > 0

                    Text {
                        id: favText
                        anchors.centerIn: parent
                        text: "♥ " + (root.modelData && root.modelData.favorites ? root.modelData.favorites : 0)
                        font.pixelSize: 9
                        color: "#ff6b6b"
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.displayName
                font.pixelSize: 10
                color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            anchors.fill: parent
            color: ThemeManager.selectedTheme.colors.primary.alpha(0.4)
            visible: root.isDownloading
            radius: parent.radius
            z: 10
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6
                BusyIndicator {
                    width: 32
                    height: 32
                    running: root.isDownloading
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Downloading..."
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        MouseArea {
            id: itemMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked(root.modelData)
        }
    }
}

// components/wallpaper_selector/WallpaperCard.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"

Item {
    id: root

    // -- 1. Required Properties --
    required property var modelData
    required property int index

    // -- 2. State Properties --
    property bool isWallhaven: false
    property bool isHovered: hoverHandler.hovered
    property bool isDownloading: false
    property string currentWallpaper: ""

    // -- 3. Calculated Properties (Read-only) --
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

    // -- 4. Signals --
    signal downloadAndApply(var wallpaperData)
    signal downloadOnly(var wallpaperData)
    signal preview(var wallpaperData)

    // -- 5. Main Visual Elements --
    Rectangle {
        id: cardBackground
        anchors.fill: parent
        anchors.margins: 4

        // Styling
        radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
        color: mainMouseArea.containsMouse ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.15) || "#333" : "transparent"
        border.color: root.currentWallpaper === root.wallpaperPath ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : mainMouseArea.containsMouse ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.5) || "#555" : "transparent"
        border.width: root.currentWallpaper === root.wallpaperPath ? 2 : 1
        z: 1

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        HoverHandler {
            id: hoverHandler
        }

        // -- Content Layout --
        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            // Thumbnail Area
            Rectangle {
                id: thumbnailContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: (ThemeManager.selectedTheme?.dimensions?.elementRadius || 8) - 2
                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#111"
                clip: true

                Image {
                    id: thumbnailImage
                    anchors.fill: parent
                    source: root.thumbUrl

                    // يحافظ على تعبئة المكان دون تشويه الصورة (يقص الزوائد)
                    fillMode: Image.PreserveAspectFit

                    asynchronous: true
                    sourceSize: Qt.size(300, 0)
                }

                // Loading Spinner
                Rectangle {
                    id: loadingSpinner
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                    visible: thumbnailImage.status === Image.Loading

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.pixelSize: 14
                        font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                        color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"

                        RotationAnimation on rotation {
                            running: thumbnailImage.status === Image.Loading
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }

                // Favorites Badge (Wallhaven specific)
                Rectangle {
                    id: wallhavenBadge
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 4
                    height: 16
                    width: favCountText.width + 8
                    radius: 4
                    color: "#000000aa"
                    visible: root.isWallhaven && root.modelData && (root.modelData.favorites || 0) > 0

                    Text {
                        id: favCountText
                        anchors.centerIn: parent
                        text: "♥ " + (root.modelData && root.modelData.favorites ? root.modelData.favorites : 0)
                        font.pixelSize: 9
                        color: "#ff6b6b"
                    }
                }
            }

            // Name Label
            Text {
                id: wallpaperLabel
                Layout.fillWidth: true
                text: root.displayName
                font.pixelSize: 10
                color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // -- Download Overlay --
        Rectangle {
            id: downloadingOverlay
            anchors.fill: parent
            z: 999
            color: ThemeManager.selectedTheme.colors.primary.alpha(0.4)
            visible: root.isDownloading
            radius: parent.radius

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    width: 32
                    height: 32
                    running: root.isDownloading
                }
                Text {
                    text: "Downloading..."
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        // -- Main Interaction Area --
        MouseArea {
            id: mainMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.downloadAndApply(root.modelData);
            }
        }

        // -- Floating Action Buttons --
        Row {
            id: actionButtonsRow
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            spacing: 0
            visible: root.isHovered
            z: 100

            ActionButton {
                id: previewButton
                iconSymbol: "󰈈"
                onActionTriggered: {
                    root.preview(root.modelData);
                }
            }

            ActionButton {
                id: downloadButton
                iconSymbol: "󰇚"
                visible: root.isWallhaven
                onActionTriggered: {
                    root.downloadOnly(root.modelData);
                }
            }
        }
    }

    // -- Sub-Components --
    component ActionButton: Item {
        id: btnRoot

        property string iconSymbol: ""
        signal actionTriggered

        width: 36
        height: 36

        Rectangle {
            id: btnBackground
            anchors.centerIn: parent

            // Size logic (hover animation)
            width: btnMouseArea.containsMouse ? 32 : 28
            height: width
            radius: width / 2

            color: btnMouseArea.containsMouse ? (ThemeManager.selectedTheme?.colors?.primary || "#6366f1") : "#99000000"
            border.width: 1
            border.color: btnMouseArea.containsMouse ? (ThemeManager.selectedTheme?.colors?.onPrimary || "#ffffff") : (ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#55ffffff")

            // Animations
            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                id: btnIcon
                anchors.fill: parent
                text: btnRoot.iconSymbol
                font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"

                // Slight scale on hover
                font.pixelSize: btnMouseArea.containsMouse ? 16 : 14
                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: 150
                    }
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering

                color: btnMouseArea.containsMouse ? (ThemeManager.selectedTheme?.colors?.onPrimary || "#ffffff") : (ThemeManager.selectedTheme?.colors?.primary || "#ffffff")
            }
        }

        MouseArea {
            id: btnMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            onClicked: btnRoot.actionTriggered()
        }
    }
}

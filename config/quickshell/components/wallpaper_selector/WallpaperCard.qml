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
    readonly property var theme: ThemeManager.selectedTheme

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
        radius: root.theme.dimensions.elementRadius
        color: mainMouseArea.containsMouse ? root.theme.colors.primary.alpha(0.15) : "transparent"
        border.color: root.currentWallpaper === root.wallpaperPath ? root.theme.colors.primary : mainMouseArea.containsMouse ? root.theme.colors.primary.alpha(0.5) : "transparent"
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

                radius: root.theme.dimensions.elementRadius - 2
                color: root.theme.colors.leftMenuBgColorV1
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
                    color: root.theme.colors.primary.alpha(0.3)
                    visible: thumbnailImage.status === Image.Loading

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.pixelSize: 14
                        font.family: root.theme.typography.iconFont
                        color: root.theme.colors.primary

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
                    color: root.theme.colors.topbarColor.alpha(0.72)
                    visible: root.isWallhaven && root.modelData && (root.modelData.favorites || 0) > 0

                    Text {
                        id: favCountText
                        anchors.centerIn: parent
                        text: "♥ " + (root.modelData && root.modelData.favorites ? root.modelData.favorites : 0)
                        font.pixelSize: 9
                        color: root.theme.colors.error
                    }
                }
            }

            // Name Label
            Text {
                id: wallpaperLabel
                Layout.fillWidth: true
                text: root.displayName
                font.pixelSize: 10
                color: root.theme.colors.subtleText
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // -- Download Overlay --
        Rectangle {
            id: downloadingOverlay
            anchors.fill: parent
            z: 999
            color: root.theme.colors.primary.alpha(0.4)
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
                    color: root.theme.colors.onPrimary
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

            color: btnMouseArea.containsMouse ? root.theme.colors.primary : root.theme.colors.topbarColor.alpha(0.6)
            border.width: 1
            border.color: btnMouseArea.containsMouse ? root.theme.colors.onPrimary : root.theme.colors.primary.alpha(0.3)

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
                font.family: root.theme.typography.iconFont

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

                color: btnMouseArea.containsMouse ? root.theme.colors.onPrimary : root.theme.colors.primary
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

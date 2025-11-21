import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell.Services.Mpris

import "root:/themes"
import "root:/components"
import "root:/config"

Item {
    id: root

    property var player: null
    property int availablePlayersCount: 0

    readonly property string identity: (player && player.identity) ? player.identity : "Media Player"
    readonly property string title: (player && player.trackTitle) ? player.trackTitle : "No Media"
    readonly property string artist: (player && player.trackArtist) ? player.trackArtist : "Unknown Artist"
    readonly property string albumArt: (player && player.trackArtUrl) ? player.trackArtUrl : ""
    readonly property bool isPlaying: player ? player.isPlaying : false

    readonly property double position: player ? player.position : 0
    readonly property double length: (player && player.length > 0) ? player.length : 1
    readonly property double progress: position / length

    property bool isScrubbing: seekSlider.pressed
    property alias pressed: mouseArea.pressed

    signal switchPlayerClicked

    implicitHeight: 180

    NibrasShellShortcut {
        id: nextSongShortcut
        name: "nextSong"
        onPressed: root.player.next()
    }

    NibrasShellShortcut {
        id: previousSongShortcut
        name: "previousSong"
        onPressed: root.player.previous()
    }

    NibrasShellShortcut {
        id: togglePlayingShortcut
        name: "togglePlaying"
        onPressed: root.player.togglePlaying()
    }

    NibrasShellShortcut {
        id: switchPlayerShortcut
        name: "switchPlayer"
        onPressed: root.switchPlayerClicked()
    }

    NibrasShellShortcut {
        id: stopPlayShortcut
        name: "stopPlay"
        onPressed: root.player.stop()
    }

    Timer {
        interval: 1000
        running: root.player && root.player.playbackState === MprisPlaybackState.Playing && !root.isScrubbing
        repeat: true
        onTriggered: if (root.player)
            root.player.positionChanged()
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "0:00";
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" + s : s);
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        preventStealing: false
    }

    RowLayout {
        anchors.fill: parent
        anchors.rightMargin: 15
        anchors.leftMargin: 15
        anchors.bottomMargin: 10
        spacing: 20

        Rectangle {
            Layout.preferredWidth: 90
            Layout.preferredHeight: 90
            Layout.alignment: Qt.AlignVCenter

            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)
            clip: true

            Image {
                anchors.fill: parent
                source: root.albumArt
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready && source !== ""
            }

            Text {
                anchors.centerIn: parent
                visible: parent.children[0].status !== Image.Ready || root.albumArt === ""
                text: "󰝚"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 35
                color: ThemeManager.selectedTheme.colors.onPrimary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    height: 22
                    width: appIdentityRow.implicitWidth + 16
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    color: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)

                    Row {
                        id: appIdentityRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: ""
                            font.family: ThemeManager.selectedTheme.typography.iconFont
                            font.pixelSize: 10
                            color: ThemeManager.selectedTheme.colors.onPrimary
                            opacity: 0.8
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.identity
                            font.bold: true
                            font.pixelSize: 10
                            color: ThemeManager.selectedTheme.colors.onPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                MButton {
                    visible: root.availablePlayersCount > 1

                    text: "󰌳"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 12

                    implicitWidth: 24
                    implicitHeight: 24

                    normalBackground: "transparent"
                    normalForeground: ThemeManager.selectedTheme.colors.onPrimary
                    hoveredBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)

                    ToolTip.visible: hovered
                    ToolTip.text: "Switch Player"
                    ToolTip.delay: 500

                    onClicked: root.switchPlayerClicked()
                }
            }

            Item {
                Layout.fillHeight: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.title
                    Layout.fillWidth: true
                    font.bold: true
                    font.pixelSize: 15
                    color: ThemeManager.selectedTheme.colors.onPrimary
                    elide: Text.ElideRight
                }
                Text {
                    text: root.artist
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: ThemeManager.selectedTheme.colors.onPrimary
                    opacity: 0.7
                    elide: Text.ElideRight
                }
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.formatTime(root.position)
                    font.pixelSize: 10
                    font.bold: true
                    color: ThemeManager.selectedTheme.colors.onPrimary
                }

                Slider {
                    id: seekSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10

                    from: 0.0
                    to: 1.0
                    Binding on value {
                        when: !seekSlider.pressed
                        value: root.progress
                    }
                    onMoved: {
                        if (root.player && root.player.canSeek) {
                            if (root.player.positionSupported)
                                root.player.position = value * root.player.length;
                            else
                                root.player.seek((value * root.player.length) - root.player.position);
                            root.player.positionChanged();
                        }
                    }
                    Material.accent: ThemeManager.selectedTheme.colors.onPrimary
                    Material.theme: Material.Dark
                }

                Text {
                    text: root.formatTime(root.length)
                    font.pixelSize: 10
                    font.bold: true
                    color: ThemeManager.selectedTheme.colors.onPrimary
                }
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 25
                Layout.bottomMargin: 2

                MButton {
                    text: ""
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 20
                    implicitWidth: 35
                    implicitHeight: 35
                    normalBackground: "transparent"
                    normalForeground: ThemeManager.selectedTheme.colors.onPrimary
                    hoveredBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)
                    enabled: root.player && root.player.canGoPrevious
                    opacity: enabled ? 1 : 0.5
                    onClicked: root.player.previous()
                }

                MButton {
                    text: root.isPlaying ? "" : ""
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 24
                    implicitWidth: 45
                    implicitHeight: 45

                    normalBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)
                    hoveredBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.3)
                    normalForeground: ThemeManager.selectedTheme.colors.onPrimary
                    enabled: root.player && root.player.canTogglePlaying
                    onClicked: root.player.togglePlaying()
                }

                MButton {
                    text: ""
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 20
                    implicitWidth: 35
                    implicitHeight: 35
                    normalBackground: "transparent"
                    normalForeground: ThemeManager.selectedTheme.colors.onPrimary
                    hoveredBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)
                    enabled: root.player && root.player.canGoNext
                    opacity: enabled ? 1 : 0.5
                    onClicked: root.player.next()
                }
            }
        }
    }
}

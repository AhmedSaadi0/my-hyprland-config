import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Shapes 1.15

import "root:/themes"
import "root:/services"
import "root:/components"
import "root:/windows/smart_capsule/logic"

Item {
    id: root

    // ============================================================
    //  1. CONFIGURATION (Style from ThemeManager)
    // ============================================================
    QtObject {
        id: style
        property color textPrimary: CapsuleManager.fgColor
        property color textSecondary: textPrimary.alpha(0.7)
        property color bgSurface: textPrimary.alpha(0.1)
        property color bgHover: textPrimary.alpha(0.2)
        property color bgActive: textPrimary.alpha(0.3)

        property string iconFont: (ThemeManager.selectedTheme && ThemeManager.selectedTheme.typography) ? ThemeManager.selectedTheme.typography.iconFont : ""
        property int fontSizeTitle: 15
        property int fontSizeSub: 13
        property int fontSizeTiny: 10
        property real radius: ThemeManager.selectedTheme.dimensions.elementRadius
    }

    // ============================================================
    //  2. LOGIC & STATE (Bound to MusicService)
    // ============================================================

    readonly property bool hasPlayer: MusicService.hasPlayer
    readonly property bool isPlaying: MusicService.isPlaying
    readonly property string title: MusicService.title
    readonly property string artist: MusicService.artist
    readonly property string coverArt: MusicService.coverArt
    readonly property string identity: MusicService.activePlayer ? MusicService.activePlayer.identity : "Media Player"

    property var player: MusicService.activePlayer

    readonly property double progress: MusicService.progress
    readonly property double position: MusicService.position
    readonly property double length: MusicService.length

    property bool isScrubbing: seekSlider.pressed

    implicitHeight: 170
    implicitWidth: 300

    Timer {
        interval: 1000
        running: root.isPlaying && !root.isScrubbing
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

    // ============================================================
    //  3. COMPONENTS (Local Components)
    // ============================================================

    // --- مكون النص المتحرك (Queue Text) ---
    component QueueText: Item {
        property string text: ""
        property font font
        property color color
        property bool fontBold: false
        property int pixelSize: 12
        property var capitalization: Font.MixedCase
        property real opacityValue: 1.0

        Layout.fillWidth: true
        implicitHeight: currentText.implicitHeight
        clip: true

        Item {
            id: slideContainer
            height: parent.height
            width: parent.width * 2
            x: 0

            Text {
                id: currentText
                width: parent.width / 2
                height: parent.height
                text: parent.parent.text
                font: parent.parent.font
                color: parent.parent.color
                elide: Text.ElideRight
                // font.bold: parent.parent.fontBold
                // font.pixelSize: parent.parent.pixelSize
                // font.capitalization: parent.parent.capitalization
                verticalAlignment: Text.AlignVCenter
                opacity: parent.parent.opacityValue
            }

            Text {
                id: nextText
                x: parent.width / 2
                width: parent.width / 2
                height: parent.height
                font: currentText.font
                color: currentText.color
                elide: currentText.elide
                // font.bold: currentText.font.bold
                // font.pixelSize: currentText.font.pixelSize
                // font.capitalization: currentText.font.capitalization
                verticalAlignment: Text.AlignVCenter
                opacity: currentText.opacity
            }

            NumberAnimation {
                id: slideAnim
                target: slideContainer
                property: "x"
                to: -root.width
                duration: 400
                easing.type: Easing.OutCirc
                onFinished: {
                    currentText.text = nextText.text;
                    slideContainer.x = 0;
                }
            }
        }

        onTextChanged: {
            if (currentText.text !== text) {
                nextText.text = text;
                slideAnim.to = -width;
                slideAnim.start();
            }
        }
    }

    // --- زر التشغيل المتحول (Morphing Play Button) ---
    component MorphPlayButton: MouseArea {
        property bool playing: false
        property color iconColor: "white"

        implicitWidth: 50
        implicitHeight: 40
        hoverEnabled: true

        Rectangle {
            anchors.fill: parent
            color: parent.pressed ? style.bgActive : (parent.containsMouse ? style.bgHover : style.bgSurface)
            radius: style.radius
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        Item {
            anchors.centerIn: parent
            width: 20
            height: 20
            clip: true

            // Pause Icon
            Item {
                anchors.fill: parent
                opacity: playing ? 1 : 0
                rotation: playing ? 0 : -90
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
                Behavior on rotation {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }

                Rectangle {
                    x: 5
                    height: 16
                    width: 4
                    y: 2
                    color: iconColor
                    radius: 1
                }
                Rectangle {
                    x: 13
                    height: 16
                    width: 4
                    y: 2
                    color: iconColor
                    radius: 1
                }
            }

            // Play Icon
            Text {
                anchors.centerIn: parent
                text: ""
                font.family: style.iconFont || ""
                font.pixelSize: 20
                color: iconColor
                opacity: playing ? 0 : 1
                rotation: playing ? 90 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
                Behavior on rotation {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
    }

    // ============================================================
    //  4. VISUAL LAYOUT
    // ============================================================

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // --- Cover Art ---
        Rectangle {
            Layout.preferredHeight: 130
            Layout.preferredWidth: 130
            Layout.alignment: Qt.AlignVCenter
            radius: style.radius
            color: style.bgSurface
            clip: true

            Image {
                id: albumImage
                anchors.fill: parent
                source: root.coverArt
                fillMode: Image.PreserveAspectCrop

                onSourceChanged: {
                    scale = 1.1;
                    opacity = 0;
                }
                onStatusChanged: {
                    if (status === Image.Ready)
                        imageAppearAnim.start();
                }

                ParallelAnimation {
                    id: imageAppearAnim
                    NumberAnimation {
                        target: albumImage
                        property: "opacity"
                        to: 1
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: albumImage
                        property: "scale"
                        to: 1.0
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: albumImage.status !== Image.Ready || root.coverArt === ""
                text: "󰝚"
                font.family: style.iconFont
                font.pixelSize: 40
                color: style.textPrimary
                opacity: 0.5
            }
        }

        // --- Right Section (Info & Controls) ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            // 1. Info Row (Title, Artist, Player Name)
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    QueueText {
                        text: root.identity
                        pixelSize: 9
                        color: style.textSecondary
                        opacityValue: 0.8
                        fontBold: true
                        capitalization: Font.AllUppercase
                    }

                    QueueText {
                        text: root.title
                        fontBold: true
                        pixelSize: 14
                        color: style.textPrimary
                    }

                    QueueText {
                        text: root.artist
                        pixelSize: 12
                        color: style.textSecondary
                    }
                }

                // Switch Player Button
                MButton {
                    // visible: MusicService._players.length > 1 // يمكن استخدام الخاصية الخاصة من الخدمة
                    text: "󰌳"
                    font.family: style.iconFont
                    font.pixelSize: 14
                    implicitWidth: 24
                    implicitHeight: 24
                    normalBackground: "transparent"
                    normalForeground: style.textSecondary
                    onClicked: MusicService.cyclePlayers()
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }

            // 2. Progress Slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -5

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.formatTime(root.position)
                        font.pixelSize: 9
                        color: style.textSecondary
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.formatTime(root.length)
                        font.pixelSize: 9
                        color: style.textSecondary
                    }
                }

                FlatSlider {
                    id: seekSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10

                    value: (!pressed) ? root.progress : value
                    enableChangeOnWheel: false

                    onMoved: {
                        if (root.player && root.player.canSeek) {
                            if (root.player.positionSupported)
                                root.player.position = value * root.player.length;
                            else
                                root.player.seek((value * root.player.length) - root.player.position);
                            root.player.positionChanged();
                        }
                    }

                    activeColor: style.textPrimary
                    inactiveColor: style.bgSurface
                    lineWidth: 4
                }
            }

            // 3. Controls (Media Buttons & Volume)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 5
                spacing: 10

                // Media Buttons
                RowLayout {
                    spacing: 15

                    MButton {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 18
                        implicitWidth: 30
                        implicitHeight: 30
                        normalBackground: "transparent"
                        normalForeground: style.textPrimary
                        // enabled: root.player && root.player.canGoPrevious
                        opacity: enabled ? 1 : 0.5
                        onClicked: MusicService.prev()
                    }

                    MorphPlayButton {
                        playing: root.isPlaying
                        iconColor: style.textPrimary
                        // enabled: root.player && root.player.canTogglePlaying
                        onClicked: MusicService.toggle()
                    }

                    MButton {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 18
                        implicitWidth: 30
                        implicitHeight: 30
                        normalBackground: "transparent"
                        normalForeground: style.textPrimary
                        // enabled: root.player && root.player.canGoNext
                        opacity: enabled ? 1 : 0.5
                        onClicked: MusicService.next()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Volume Control (Using SystemService)
                RowLayout {
                    spacing: 10

                    Text {
                        text: Audio.muted ? "" : (Audio.volume > 0.5 ? "" : "")
                        font.family: style.iconFont
                        font.pixelSize: 14
                        color: style.textSecondary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Audio.setVolume(Audio.volume > 0 ? 0 : 0.5)
                        }
                    }

                    FlatSlider {
                        id: volSlider
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 20

                        Component.onCompleted: volSlider.value = Audio.volume
                        Connections {
                            target: Audio
                            function onVolumeChanged() {
                                if (!volSlider.pressed && Math.abs(volSlider.value - Audio.volume) > 0.01) {
                                    volSlider.value = Audio.volume;
                                }
                            }
                        }
                        onMoved: Audio.setVolume(value)
                        onValueChanged: {
                            if (Math.abs(Audio.volume - value) > 0.01) {
                                Audio.setVolume(value);
                            }
                        }
                        activeColor: style.textSecondary
                        inactiveColor: style.bgSurface
                        lineWidth: 4
                    }
                }
            }
        }
    }
}

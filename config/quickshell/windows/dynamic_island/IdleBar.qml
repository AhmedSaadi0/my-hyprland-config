// windows/dynamic_island/IdleBar.qml

import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

import "root:/themes"
import "root:/services"
import "./widgets"

Item {
    id: root

    // ============================================================
    //  CONFIGURATION (Edit these values to change appearance) TODO: -> Control them using ThemeManager
    // ============================================================

    // -- Animations --
    property int animSpeedFast: 250      // Progress bar, fades
    property int animSpeedNormal: 300    // Slide movements
    property int animSpeedSlow: 600      // Background fade in/out
    property int colorCycleDuration: 2000 // Time between color shifts in music bg
    property int infoDisplayTime: 3000   // How long info stays before reverting to clock

    // -- Colors (Music Background Gradient Phases) --
    // Phase 1: Blue/Cyan
    property color p1_start: "#4facfe"
    property color p1_mid: "#00f2fe"
    property color p1_end: "#a18cd1"

    // Phase 2: Sunset
    property color p2_start: "#fa709a"
    property color p2_mid: "#fee140"
    property color p2_end: "#ff0844"

    // Phase 3: Neon/Deep
    property color p3_start: "#30cfd0"
    property color p3_mid: "#B9429F"
    property color p3_end: "#5b86e5"

    // -- Layout & Fonts --
    property real elementRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int fontSizeIcon: 18
    property int fontSizeText: 14
    property int layoutSpacing: 5

    // ============================================================
    //  STATE & LOGIC VARIABLES (Do not edit manually)
    // ============================================================
    clip: true // Ensures content stays inside rounded corners

    signal requestExpand(string mode)

    property bool isListening: true
    property string activeMode: "clock" // "clock" or "info"
    property string overlayIcon: ""
    property string overlayText: ""

    property real progressValue: 0.0
    property bool showProgress: false
    property bool isHoverMode: false

    property var activePlayer: null
    // property bool hasActivePlayer: activePlayer !== null

    // Music playing state (Uncomment the readonly property in production)
    property bool isMusicPlaying: activePlayer ? activePlayer.isPlaying : false
    // readonly property bool isMusicPlaying: activePlayer && activePlayer.playbackStatus === Mpris.PlaybackStatus.Playing

    // Calculate width dynamically based on content
    property real clockTextWidth: {
        let currentClockW = clockTxt.implicitWidth;
        let centerW = 0;
        if (activeMode === "clock" || isHoverMode) {
            centerW = currentClockW;
        } else {
            let infoW = overlayIconTxt.implicitWidth + overlayMainTxt.implicitWidth;
            centerW = Math.max(infoW, Math.max(currentClockW, 150));
        }
        let sideIconsW = 40;
        // if (hasActivePlayer)
        sideIconsW += 20; // Make music player visiable all the time for better look
        return centerW + sideIconsW + 10;
    }

    // ============================================================
    //  LOGIC HANDLERS (Timers & Connections)
    // ============================================================

    onIsListeningChanged: {
        if (!isListening) {
            revertTimer.stop();
            root.activeMode = "clock";
            root.showProgress = false;
        }
    }

    // Timer to revert back to clock after showing info
    Timer {
        id: revertTimer
        interval: root.infoDisplayTime
        repeat: false
        onTriggered: {
            root.activeMode = "clock";
            root.showProgress = false;
        }
    }

    Connections {
        target: Audio
        enabled: root.isListening
        function onVolumeChanged() {
            root.overlayText = Math.round(Audio.volume * 100) + "%";
            root.overlayIcon = getVolumeIcon(Audio.volume, Audio.muted);
            root.progressValue = Audio.volume;
            root.showProgress = true;
            root.activeMode = "info";
            revertTimer.restart();
        }
    }

    Connections {
        target: Brightness
        enabled: root.isListening
        function onBrightnessChanged() {
            root.overlayText = Math.round(Brightness.brightness * 100) + "%";
            root.overlayIcon = getBrightnessIcon(Brightness.brightness);
            root.progressValue = Brightness.brightness;
            root.showProgress = true;
            root.activeMode = "info";
            revertTimer.restart();
        }
    }

    Connections {
        target: activePlayer
        ignoreUnknownSignals: true
        enabled: root.isListening
        function onMetadataChanged() {
            showMediaInfo();
        }
        function onPlaybackStatusChanged() {
            showMediaInfo();
        }
    }

    Connections {
        target: Weather
        enabled: root.isListening
        function onChanceOfRainNotified(msg) {
            showWeatherAlert("", "Rain Expected");
        }
        function onChanceOfSnowNotified(msg) {
            showWeatherAlert("", "Snow Expected");
        }
        function onChanceOfThunderNotified(msg) {
            showWeatherAlert("", "Thunderstorm");
        }
        function onChanceOfFogNotified(msg) {
            showWeatherAlert("", "Fog Warning");
        }
        function onChanceOfWindyNotified(msg) {
            showWeatherAlert("", "High Wind");
        }
        function onChanceOfHotWeatherNotified(msg) {
            showWeatherAlert("", "High Temp");
        }
        function onChanceOfFrostNotified(msg) {
            showWeatherAlert("", "Frost Warning");
        }
    }

    // Helper Functions
    function showWeatherAlert(icon, text) {
        root.overlayIcon = icon;
        root.overlayText = text;
        root.showProgress = false;
        root.activeMode = "info";
        revertTimer.restart();
    }

    function showMediaInfo() {
        if (!activePlayer)
            return;
        var title = activePlayer.trackTitle || "Unknown";
        var artist = activePlayer.trackArtist || "";
        root.overlayIcon = "󰝚";
        root.overlayText = (artist !== "") ? artist + " - " + title : title;
        root.showProgress = false;
        root.activeMode = "info";
        revertTimer.restart();
    }

    function getVolumeIcon(vol, muted) {
        if (muted)
            return "";
        if (vol < 0.30)
            return "";
        if (vol < 0.70)
            return "";
        return "";
    }

    function getBrightnessIcon(val) {
        if (val < 0.30)
            return "󰃞";
        if (val < 0.70)
            return "󰃟";
        return "󰃠";
    }

    // ============================================================
    //  VISUAL LAYERS
    // ============================================================

    // 1. Music Animated Background
    Rectangle {
        id: musicInternalBg
        anchors.fill: parent
        radius: root.elementRadius
        opacity: root.isMusicPlaying ? 1.0 : 0.0
        visible: opacity > 0

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                id: gradStart
                position: 0.0
                color: root.p1_start
            }
            GradientStop {
                id: gradMid
                position: 0.5
                color: root.p1_mid
            }
            GradientStop {
                id: gradEnd
                position: 1.0
                color: root.p1_end
            }
        }

        SequentialAnimation {
            running: root.isMusicPlaying
            loops: Animation.Infinite

            // Shift to Phase 2
            ParallelAnimation {
                ColorAnimation {
                    target: gradStart
                    property: "color"
                    to: root.p2_start
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
                ColorAnimation {
                    target: gradMid
                    property: "color"
                    to: root.p2_mid
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
                ColorAnimation {
                    target: gradEnd
                    property: "color"
                    to: root.p2_end
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
            }
            // Shift to Phase 3
            ParallelAnimation {
                ColorAnimation {
                    target: gradStart
                    property: "color"
                    to: root.p3_start
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
                ColorAnimation {
                    target: gradMid
                    property: "color"
                    to: root.p3_mid
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
                ColorAnimation {
                    target: gradEnd
                    property: "color"
                    to: root.p3_end
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
            }
            // Return to Phase 1
            ParallelAnimation {
                ColorAnimation {
                    target: gradStart
                    property: "color"
                    to: root.p1_start
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
                ColorAnimation {
                    target: gradMid
                    property: "color"
                    to: root.p1_mid
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
                ColorAnimation {
                    target: gradEnd
                    property: "color"
                    to: root.p1_end
                    duration: root.colorCycleDuration
                    easing.type: Easing.InOutSine
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animSpeedSlow
            }
        }
    }

    // 2. Glossy Shine Overlay
    // Rectangle {
    //     anchors.fill: parent
    //     radius: root.elementRadius
    //     color: "transparent"
    //     opacity: root.isMusicPlaying ? 1.0 : 0.0
    //     gradient: Gradient {
    //         orientation: Gradient.Vertical
    //         GradientStop {
    //             position: 0.0
    //             color: "#40FFFFFF"
    //         }
    //         GradientStop {
    //             position: 0.5
    //             color: "transparent"
    //         }
    //         GradientStop {
    //             position: 1.0
    //             color: "#10000000"
    //         }
    //     }
    // }

    // 3. Progress Bar (Volume/Brightness)
    Rectangle {
        id: progressBar
        height: parent.height
        width: parent.width * root.progressValue
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        radius: root.elementRadius
        color: "#FFFFFF"
        opacity: 0.3
        visible: root.activeMode === "info" && root.showProgress

        Behavior on width {
            NumberAnimation {
                duration: root.animSpeedFast
                easing.type: Easing.OutQuad
            }
        }
    }

    // 4. Main Content Row (Weather, Clock, Media)
    RowLayout {
        id: widgetContainer
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        clip: true
        spacing: root.layoutSpacing

        // -- Weather Widget --
        Item {
            id: weatherItem
            Layout.preferredWidth: 24
            Layout.fillHeight: true

            Text {
                id: weatherIconText
                anchors.centerIn: parent
                text: Weather.weatherIcon !== "" ? Weather.weatherIcon : "☁"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: root.fontSizeIcon
                font.bold: true
                color: root.isMusicPlaying ? "#000000" : ThemeManager.selectedTheme.colors.onPrimary
                opacity: weatherMouse.containsMouse ? 1.0 : 0.9
            }

            MouseArea {
                id: weatherMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestExpand("weather")
                onEntered: {
                    revertTimer.stop();
                    root.overlayIcon = Weather.weatherIcon !== "" ? Weather.weatherIcon : "☁";
                    root.overlayText = Weather.currentTemp + "° - " + Weather.weatherDescription;
                    root.isHoverMode = true;
                    root.showProgress = false;
                    root.activeMode = "info";
                }
                onExited: {
                    root.isHoverMode = false;
                    root.activeMode = "clock";
                }
            }
        }

        // -- Center Container (Swaps between Clock & Info) --
        Item {
            id: centerContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Clock View
            Item {
                id: clockItem
                anchors.centerIn: parent
                width: clockTxt.implicitWidth
                height: parent.height
                transform: Translate {
                    id: clockTrans
                    y: 0
                }

                SystemClock {
                    id: sysClock
                    precision: SystemClock.Minutes
                }
                Text {
                    id: clockTxt
                    anchors.centerIn: parent
                    text: sysClock.date.toLocaleString(Qt.locale(), "hh:mm AP - dddd, dd MMMM yyyy")
                    font.bold: true
                    font.pixelSize: root.fontSizeText
                    color: root.isMusicPlaying ? "#000000" : ThemeManager.selectedTheme.colors.onPrimary
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Info View (Notification/Player/Progress)
            Item {
                id: overlayItem
                anchors.centerIn: parent
                width: widgetContainer.implicitWidth
                height: parent.height
                opacity: 0
                transform: Translate {
                    id: overlayTrans
                    y: 20
                }

                Row {
                    id: overlayRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        id: overlayIconTxt
                        text: root.overlayIcon
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: root.fontSizeText
                        color: root.isMusicPlaying ? "#000000" : ThemeManager.selectedTheme.colors.onPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: overlayMainTxt
                        text: root.overlayText
                        font.bold: true
                        font.pixelSize: root.fontSizeText
                        color: root.isMusicPlaying ? "#000000" : ThemeManager.selectedTheme.colors.onPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, 500)
                        elide: Text.ElideRight
                    }
                }
            }

            // State Handling for Animations
            states: [
                State {
                    name: "clock"
                    when: root.activeMode === "clock"
                    PropertyChanges {
                        target: clockItem
                        opacity: 1
                    }
                    PropertyChanges {
                        target: clockTrans
                        y: 0
                    }
                    PropertyChanges {
                        target: overlayItem
                        opacity: 0
                    }
                    PropertyChanges {
                        target: overlayTrans
                        y: 20
                    }
                },
                State {
                    name: "info"
                    when: root.activeMode === "info"
                    PropertyChanges {
                        target: clockItem
                        opacity: 0
                    }
                    PropertyChanges {
                        target: clockTrans
                        y: -20
                    }
                    PropertyChanges {
                        target: overlayItem
                        opacity: 1
                    }
                    PropertyChanges {
                        target: overlayTrans
                        y: 0
                    }
                }
            ]

            transitions: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        duration: root.animSpeedFast
                    }
                    NumberAnimation {
                        property: "y"
                        duration: root.animSpeedNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // -- Media Widget --
        Item {
            Layout.preferredWidth: 24
            Layout.fillHeight: true
            // visible: root.hasActivePlayer

            MusicVisualizer {
                anchors.centerIn: parent
                playing: root.activePlayer && root.activePlayer.isPlaying
                opacity: mediaMouse.containsMouse ? 1.0 : 0.9
            }

            MouseArea {
                id: mediaMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestExpand("media")
                onEntered: {
                    if (root.activePlayer) {
                        revertTimer.stop();
                        var title = root.activePlayer.trackTitle || "Unknown";
                        var artist = root.activePlayer.trackArtist || "";
                        root.overlayIcon = "󰝚";
                        root.overlayText = (artist !== "") ? artist + " - " + title : title;
                        root.isHoverMode = true;
                        root.showProgress = false;
                        root.activeMode = "info";
                    }
                }
                onExited: {
                    root.isHoverMode = false;
                    root.activeMode = "clock";
                }
            }
        }
    }
}

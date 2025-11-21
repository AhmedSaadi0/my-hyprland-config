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
    clip: true

    signal requestExpand(string mode)

    property bool isListening: true

    property string activeMode: "clock"
    property string overlayIcon: ""
    property string overlayText: ""

    property real progressValue: 0.0
    property bool showProgress: false

    property var activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property bool hasActivePlayer: activePlayer !== null

    property real clockTextWidth: {
        // 1. نحسب عرض الساعة الحالية (كمرجع)
        let currentClockW = clockTxt.implicitWidth;

        let centerW = 0;

        if (activeMode === "clock") {
            centerW = currentClockW;
        } else {
            // نحن في وضع المعلومات (صوت/سطوع/موسيقى)
            let infoW = overlayIconTxt.implicitWidth + overlayMainTxt.implicitWidth;

            // نختار القيمة الأكبر بين:
            // 1. عرض المعلومات الفعلي
            // 2. عرض الساعة (لكي لا ينكمش البار فجأة)
            // 3. حد أدنى ثابت (مثلاً 150px) لضمان أن شريط التقدم له مساحة كافية للظهور
            centerW = Math.max(infoW, Math.max(currentClockW, 150));
        }

        let sideIconsW = 0;
        sideIconsW += 20; // الطقس
        if (hasActivePlayer)
            sideIconsW += 20; // الموسيقى

        return centerW + sideIconsW + 10;
    }

    onIsListeningChanged: {
        if (!isListening) {
            // 1. إيقاف العد التنازلي فوراً
            revertTimer.stop();

            // 2. (اختياري ولكنه أفضل) إعادة الوضع للساعة في الخلفية
            // حتى عندما تغلق الجزيرة لاحقاً، تجد الساعة بانتظارك وليس نص الأغنية القديم
            root.activeMode = "clock";
            root.showProgress = false;
        }
    }

    Timer {
        id: revertTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.activeMode = "clock";
            root.showProgress = false;
        }
    }

    Rectangle {
        id: progressBar
        height: parent.height
        width: parent.width * root.progressValue
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.25)

        visible: root.activeMode === "info" && root.showProgress

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
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
        // showMediaInfoStatus();
        }
        function onIsPlayingChanged() {
        // showMediaInfoStatus();
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
        if (artist !== "")
            root.overlayText = artist + " - " + title;
        else
            root.overlayText = title;

        root.showProgress = false;
        root.activeMode = "info";
        revertTimer.restart();
    }

    function showMediaInfoStatus() {
        if (!activePlayer)
            return;
        var isPlaying = activePlayer.isPlaying;
        var status = isPlaying ? "Playing" : "Paused";
        var icon = isPlaying ? "" : "";

        root.overlayIcon = icon;
        root.overlayText = status;

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

    RowLayout {
        id: widgetContainer
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        clip: true

        spacing: 5

        // -------------------
        // ----- Weather -----
        // -------------------
        Item {
            id: weatherItem
            Layout.preferredWidth: 24
            Layout.fillHeight: true

            Text {
                id: weatherIconText
                anchors.centerIn: parent
                text: Weather.weatherIcon !== "" ? Weather.weatherIcon : "☁"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 18
                color: ThemeManager.selectedTheme.colors.onPrimary
                opacity: weatherMouse.containsMouse ? 1.0 : 0.7
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            MouseArea {
                id: weatherMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestExpand("weather")

                ToolTip.visible: hovered
                ToolTip.text: Weather.currentTemp + "° - " + Weather.weatherDescription
                ToolTip.delay: 500
            }
        }

        // --------------------
        // ------ Center ------
        // Clock, volume progress, brightness progress, and information
        // --------------------
        Item {
            id: centerContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

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
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.onPrimary
                    verticalAlignment: Text.AlignVCenter
                }
            }

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
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: overlayMainTxt
                        text: root.overlayText
                        font.bold: true
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter

                        width: Math.min(implicitWidth, 500)
                        elide: Text.ElideRight
                    }
                }
            }

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
                        duration: 200
                    }
                    NumberAnimation {
                        property: "y"
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // -------------------
        // ----- Media -------
        // -------------------
        Item {
            Layout.preferredWidth: 24
            Layout.fillHeight: true
            visible: root.hasActivePlayer

            MusicVisualizer {
                anchors.centerIn: parent

                playing: root.activePlayer && root.activePlayer.isPlaying
                opacity: mediaMouse.containsMouse ? 1.0 : 0.7
            }

            MouseArea {
                id: mediaMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestExpand("media")
            }
        }
    }
}

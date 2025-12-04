// windows/smart_capsule/logic/CapsuleManager.qml
pragma Singleton

import QtQuick
import "root:/config/ConstValues.js" as C
import "root:/services"

QtObject {
    id: root

    // --- State ---
    property int currentPriority: C.IDLE
    property string activeSource: ""

    property string displayIcon: ""
    property string displayText: ""
    property real progressValue: 0.0
    property bool showProgress: false
    property bool changeWidth: true

    property var _timer: Timer {
        interval: 3000
        repeat: false
        onTriggered: root.reset()
    }

    function request(priority, source, icon, text, progress, withProgress, timeout, changeW = true) {
        if (priority > currentPriority || (priority === currentPriority && source === activeSource) || currentPriority === C.IDLE) {
            currentPriority = priority;
            activeSource = source;
            displayIcon = icon;
            displayText = text;
            progressValue = progress;
            showProgress = withProgress;
            changeWidth = changeW;

            _timer.stop();
            if (timeout > 0) {
                _timer.interval = timeout;
                _timer.start();
            }
        }
    }

    function reset() {
        currentPriority = C.IDLE;
        activeSource = "";
        showProgress = false;
        changeWidth = true;
    }

    // 1. مراقبة الموسيقى
    property var _musicConn: Connections {
        target: MusicService

        onFullInfoChanged: {
            if (MusicService.isPlaying)
                notifyMusic();
        }

        onIsPlayingChanged: {
            if (MusicService.isPlaying)
                notifyMusic();
        }
    }

    function notifyMusic() {
        request(C.TRANSIENT, C.SRC_MUSIC, "󰝚", MusicService.fullInfo, 0, false, 3000);
    }

    // 2. مراقبة النظام (الصوت والسطوع والبطارية)
    property var _systemConn: Connections {
        target: SystemService

        onVolumeChanged: {
            request(C.TRANSIENT, C.SRC_SYSTEM, SystemService.volumeIcon, Math.round(SystemService.volume * 100) + "%", SystemService.volume, true, 2000);
        }

        onBrightnessChanged: {
            request(C.TRANSIENT, C.SRC_SYSTEM, SystemService.brightnessIcon, Math.round(SystemService.brightness * 100) + "%", SystemService.brightness, true, 2000);
        }

        onBatteryStateChanged: {
            if (SystemService.batteryState === 1) {
                // 1 = Charging
                request(C.WARNING, C.SRC_BATTERY, SystemService.batteryIcon, "Charging " + Math.round(SystemService.batteryPercent * 100) + "%", SystemService.batteryPercent, true, 4000);
            }
        }
    }
}

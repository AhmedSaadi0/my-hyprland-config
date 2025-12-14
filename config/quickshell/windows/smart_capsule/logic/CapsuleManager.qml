// windows/smart_capsule/logic/CapsuleManager.qml
pragma Singleton

import QtQuick
import Quickshell
import "root:/services"
import "root:/config"
import "root:/themes"
import "root:/config/ConstValues.js" as C
import "root:/utils/helpers.js" as Helper

Singleton {
    id: root

    // --- State ---
    property int currentPriority: C.IDLE
    property string activeSource: ""
    property string displayIcon: ""
    property string displayText: ""
    property real progressValue: 0.0
    property bool showProgress: false
    property bool changeWidth: true
    property bool changeHeight: false
    property int _lastAlertLevel: -1

    property color bgColor1: ThemeManager.selectedTheme.colors.primary
    property color bgColor2: ThemeManager.selectedTheme.colors.secondary
    property color fgColor: ThemeManager.selectedTheme.colors.onPrimary

    Timer {
        id: _timer
        interval: 4000 // Default timeout
        repeat: false
        onTriggered: root.reset()
    }

    // --- Core Function ---
    function request({
        priority,
        source,
        icon,
        text,
        progress = null,
        withProgress = false,
        timeout = 4000,
        changeW = true,
        changeH = null,
        playTone = true,
        bgColor1 = ThemeManager.selectedTheme.colors.primary,
        bgColor2 = ThemeManager.selectedTheme.colors.secondary,
        fgColor = ThemeManager.selectedTheme.colors.onPrimary
    }) {
        if (priority >= currentPriority || currentPriority === C.IDLE) {
            currentPriority = priority;
            activeSource = source;
            displayIcon = icon;
            displayText = text;
            progressValue = progress;
            showProgress = withProgress;
            changeWidth = changeW;
            root.bgColor1 = bgColor1;
            root.bgColor2 = bgColor2;
            root.fgColor = fgColor;

            if (priority > C.TRANSIENT) {
                changeHeight = changeH ? changeH : true;
            } else {
                changeHeight = false;
            }

            _timer.stop();
            if (timeout > 0) {
                _timer.interval = timeout;
                _timer.start();
            }

            if (playTone) {
                playSmartCapsuleTone(priority);
            }
        }
    }

    function playSmartCapsuleTone(priority) {
        const nibrasAudio = App.assets.audio;
        if (priority == C.NOTIFICATION) {
            nibrasAudio.playTone(nibrasAudio.smartCapsuleNotification);
        } else if (priority == C.WARNING) {
            nibrasAudio.playTone(nibrasAudio.smartCapsuleWarning);
        } else if (priority == C.CRITICAL) {
            nibrasAudio.playTone(nibrasAudio.smartCapsuleCritical);
        }
    }

    // --- Reset Function ---
    function reset() {
        currentPriority = C.IDLE;
        activeSource = "";
        showProgress = false;
        changeWidth = true;
        changeHeight = false;

        bgColor1 = Qt.binding(function () {
            return ThemeManager.selectedTheme.colors.primary;
        });
        bgColor2 = Qt.binding(function () {
            return ThemeManager.selectedTheme.colors.secondary;
        });
        fgColor = Qt.binding(function () {
            return ThemeManager.selectedTheme.colors.onPrimary;
        });
    }
}

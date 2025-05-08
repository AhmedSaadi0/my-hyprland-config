import QtQuick
import Quickshell.Io
import "../themes"

CircularProgress {
    id: root

    width: 22
    height: 22

    startAt: 0.4
    endAt: 0.1
    value: 0.0
    inverted: true
    rounded: true

    backgroundColor: palette.accent.alpha(0.4)
    foregroundColor: palette.accent

    property bool running: true
    property string icon: ""
    property int iconFontSize: 12
    property color iconColor: palette.accent
    property var command
    property int updateInterval: 1000
    property var onReadHandler: function (data) {
        var percent = parseFloat(data);
        if (!isNaN(percent)) {
            root.value = percent / 100.0;
        } else {
            console.warn("ReusableCpuCircularProgress: onReadHandler received non-numeric data:", data);
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: root.iconFontSize
        font.family: ThemeManager.selectedTheme.typography.iconFont
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: processId
        command: root.command

        stdout: SplitParser {
            onRead: data => {
                root.onReadHandler(data.trim());
            }
        }
        stderr: SplitParser {
            onRead: data => console.error(data)
        }
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval
        repeat: true
        running: false

        onTriggered: {
            processId.running = running;
        }
    }

    Component.onCompleted: {
        if (running) {
            updateTimer.start();
        }
        processId.running = running;
    }

    Component.onDestruction: {
        updateTimer.stop();
        processId.running = false;
    }
}

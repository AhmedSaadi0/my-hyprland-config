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

    backgroundColor: palette.accent.alpha(0.3)
    foregroundColor: palette.accent

    property bool running: true
    property string icon: ""
    property int iconFontSize: 12
    property color textColor: palette.accent
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
        color: root.textColor
        font.pixelSize: root.iconFontSize
        font.family: ColorsTheme.values.iconFont
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: cpuUsageProcess
        command: root.command

        stdout: SplitParser {
            onRead: data => {
                root.onReadHandler(data.trim());
            }
        }
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval
        repeat: true
        running: false

        onTriggered: {
            cpuUsageProcess.running = running;
        }
    }

    Component.onCompleted: {
        if (running) {
            updateTimer.start();
        }
        cpuUsageProcess.running = running;
    }

    Component.onDestruction: {
        updateTimer.stop();
        cpuUsageProcess.running = false;
    }
}

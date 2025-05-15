import QtQuick
import Quickshell.Io
import "../themes"
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

CircularProgress {
    id: root

    width: 22
    height: 20

    startAt: 0.4
    endAt: 0.1
    value: 0.0
    inverted: true
    rounded: true

    backgroundColor: palette.accent.alpha(0.4)
    foregroundColor: palette.accent

    property bool running: true
    property string icon: ""
    property int iconFontSize: 11
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
    property bool glowIcon: false

    Text {
        id: textitem
        width: 20
        height: 30
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: root.iconFontSize
        font.family: ThemeManager.selectedTheme.typography.iconFont
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        layer.enabled: true
        z: 2

        Glow {
            source: textitem
            color: "yellow"
            radius: 16
            samples: 16
            transparentBorder: true
            visible: root.glowIcon
            // active: isCharging
        }

        SequentialAnimation on opacity {
            id: glowAnimation
            NumberAnimation {
                to: 0.3
                duration: 1000
            }
            NumberAnimation {
                to: 1.0
                duration: 1000
            }
            loops: Animation.Infinite
            running: root.glowIcon
        }

        MouseArea {
            id: _mouseArea
            hoverEnabled: true
            anchors.fill: parent
        }

        ToolTip {
            text: Math.round(root.value * 100) + "%"
            visible: _mouseArea.containsMouse
            contentWidth: 30
            // x: root.mapFromItem(textItem, 0, 0).x
            // y: root.mapFromItem(textItem, 0, textItem.height).y + 40
            x: parent.x
            y: parent.y //+ 40
        }
    }

    // ToolTip
    // PanelWindow {
    //     id: hoverWindow
    //     visible: false
    //     width: 100
    //     height: 30
    //     anchors {
    //         top: parent.top
    //         left: parent.left
    //         right: parent.right
    //         bottom: parent.bottom
    //     }
    //
    //     Rectangle {
    //         anchors.fill: parent
    //         color: palette.window
    //         border.color: palette.accent
    //         radius: 4
    //     }
    //
    //     Text {
    //         text: Math.round(root.value * 100) + "%"
    //         color: palette.text
    //         font.pixelSize: 20
    //         anchors.centerIn: parent
    //     }
    // }

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

    // MouseArea {
    //     id: hoverArea
    //     anchors.fill: parent
    //     hoverEnabled: true
    //
    //     onEntered: {
    //         hoverWindow.visible = true;
    //         // hoverWindow.x = parent.width + 8; // Offset from the widget
    //         // hoverWindow.y = 0;
    //     }
    //     onExited: hoverWindow.visible = false
    // }

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

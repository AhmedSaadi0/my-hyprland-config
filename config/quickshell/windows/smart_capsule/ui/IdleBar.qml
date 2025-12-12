// windows/smart_capsule/ui/IdleBar.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:/themes"
import "root:/config/ConstValues.js" as C
import "root:/services"
import "root:/windows/smart_capsule/ui/components"
import "root:/windows/smart_capsule/logic"

Item {
    id: root

    readonly property color p1_start: "#4facfe"
    readonly property color p1_mid: "#00f2fe"
    readonly property color p1_end: "#a18cd1"
    readonly property color p2_start: "#fa709a"
    readonly property color p2_mid: "#fee140"
    readonly property color p2_end: "#ff0844"
    readonly property color p3_start: "#30cfd0"
    readonly property color p3_mid: "#B9429F"
    readonly property color p3_end: "#5b86e5"
    readonly property int colorCycleDuration: 2000

    signal requestExpand(string mode)

    readonly property bool isMusicPlaying: MusicService.isPlaying
    readonly property bool showInfo: CapsuleManager.currentPriority > C.IDLE

    readonly property color themeColor: CapsuleManager.fgColor
    readonly property color contentColor: isMusicPlaying ? "#000000" : themeColor

    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight

    // --- Width Logic ---
    property real requiredWidth: {
        if (!CapsuleManager.changeWidth) {
            return root.width;
        }
        var clockW = clockText.implicitWidth;
        var infoW = showInfo ? infoRow.implicitWidth : 0;
        var contentW = Math.max(clockW, infoW);
        return Math.max(contentW + 100, 330);
    }

    property real requiredHeight: {
        return calculateHeight();
    }

    function calculateHeight() {
        // 1. الطول الأساسي (الحد الأدنى)
        const minHeight = ThemeManager.selectedTheme.dimensions.barWidgetsHeight;

        // 2. طول العيون
        const eyesH = EyeController.currentEmotion === "idle" || "music" ? 0 : aiEyes.implicitHeight;

        // 3. طول النص
        // نتحقق أولاً هل المعلومات معروضة (showInfo)
        const textH = CapsuleManager.changeHeight ? (infoText.implicitHeight) : 0;

        // إرجاع القيمة الأكبر بين الثلاثة
        const currentHeight = Math.max(minHeight, eyesH, textH);
        return currentHeight;
    }

    Connections {
        target: CapsuleManager
        function onChangeHeightChanged() {
            requiredHeight = calculateHeight();
        }
    }

    // أنيميشن لجعل التغيير ناعماً
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }
    }

    // ============================================================
    // Music Backgrounds
    // ============================================================
    Rectangle {
        id: musicAnimatedBg
        anchors.fill: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        // تظهر فقط عند تشغيل الموسيقى
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
            running: root.isMusicPlaying && parent.visible
            loops: Animation.Infinite
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
                duration: 600
            }
        }
    }

    // Progress Bar
    Rectangle {
        height: parent.height
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: "white"
        opacity: 0.4
        anchors.left: parent.left
        visible: CapsuleManager.showProgress && root.showInfo
        width: parent.width * CapsuleManager.progressValue
        Behavior on width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    // ============================================================
    //  Content
    // ============================================================

    // 1. Weather (Left)
    Item {
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: 10

        WeatherIcon {
            anchors.centerIn: parent
            contentColor: root.contentColor

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.requestExpand("weather")

                onEntered: {
                    if (Weather) {
                        CapsuleManager.request({
                            priority: C.HOVER,
                            source: C.SRC_WEATHER,
                            icon: Weather.weatherIcon,
                            text: Weather.currentTemp + "° - " + Weather.weatherDescription,
                            timeout: 0,
                            changeW: false
                        });
                    }
                }

                onExited: {
                    CapsuleManager.reset();
                }
            }
        }
    }

    // 2. Music (Right)
    Item {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: 10

        AIEyes {
            id: aiEyes
            eyeColor: root.contentColor
            // anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: root.isMusicPlaying && EyeController.currentEmotion === "music" ? 0 : 3

            MouseArea {
                anchors.fill: parent
                onClicked: root.requestExpand("media")
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onEntered: {
                    let infoText = MusicService.activePlayer.identity;
                    if (root.isMusicPlaying) {
                        infoText = MusicService.fullInfo;
                    }
                    CapsuleManager.request({
                        priority: C.HOVER,
                        source: C.SRC_MUSIC,
                        icon: "󰝚",
                        text: infoText,
                        timeout: 0,
                        changeW: false
                    });

                    EyeController.showEmotion("happy", 2000);
                }

                onExited: {
                    CapsuleManager.reset();
                }
            }
        }
    }

    // 3. Center (Clock / Info)
    Item {
        anchors.centerIn: parent
        // height: 20
        height: infoText.height
        width: showInfo ? infoRow.implicitWidth : clockRow.implicitWidth
        clip: true

        // A. Clock
        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 5

            opacity: !root.showInfo ? 1 : 0

            transform: Translate {
                y: !root.showInfo ? 0 : -20
                Behavior on y {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                }
            }

            SystemClock {
                id: sysClock
                precision: SystemClock.Minutes
            }

            Text {
                id: clockText
                // text: Qt.formatDateTime(sysClock.date, "hh:mm AP - dddd, dd MMMM yyyy")
                text: sysClock.date.toLocaleString(Qt.locale(), "hh:mm AP - dddd, dd MMMM yyyy")
                font.bold: true
                font.pixelSize: 14
                color: root.contentColor
            }
        }

        // B. Info
        Row {
            id: infoRow
            anchors.centerIn: parent
            spacing: 8

            opacity: root.showInfo ? 1 : 0

            transform: Translate {
                y: root.showInfo ? 0 : 20
                Behavior on y {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                }
            }

            Text {
                text: CapsuleManager.displayIcon
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 14
                color: root.contentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: infoText
                text: CapsuleManager.displayText
                font.bold: true
                // font.pixelSize: root.fontSizeText
                anchors.verticalCenter: parent.verticalCenter
                color: root.contentColor
                width: Math.min(implicitWidth, CapsuleManager.changeWidth ? 500 : 220)

                wrapMode: CapsuleManager.changeHeight ? Text.Wrap : Text.NoWrap
                elide: CapsuleManager.changeHeight ? Text.ElideNone : Text.ElideRight

                // onTextChanged: {
                //     root.calculateHeight();
                // }
            }
        }
    }
}

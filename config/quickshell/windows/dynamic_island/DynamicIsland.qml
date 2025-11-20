import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

import "root:/themes"
import "root:/components"
import "root:/services"

PanelWindow {
    id: dynamicIsland

    color: "transparent"
    implicitHeight: 350
    exclusionMode: ExclusionMode.Ignore
    mask: Region {
        item: islandRect
    }
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
    }
    // --- المتغيرات ---
    property string currentMode: "idle"
    property int dropDistance: ThemeManager.selectedTheme.dimensions.barHeight

    // حالة التفاعل
    property bool isHovered: false
    property bool isInteracting: false

    // ---------------------------------------------------------
    // دالة مركزية لإظهار الـ OSD (الصوت/السطوع) بشروط محددة
    // ---------------------------------------------------------
    function showOverlay(modeName) {
        // الشرط 1: إذا كان المستخدم يضغط ويسحب بيده حالياً، لا تقاطع عمله
        if (isInteracting)
            return;

        // الشرط 2: إذا كان الماوس فوق الجزيرة، لا تغير الوضع (ربما المستخدم يقرأ إشعاراً)
        if (isHovered)
            return;

        // الحل الجذري: نوقف مؤقت "فترة السماح" القديم لكي لا يغلق الجزيرة في وجه الإشعار الجديد
        hoverGraceTimer.stop();

        // نطبق الوضع الجديد
        currentMode = modeName;

        // نعيد تشغيل مؤقت الإخفاء (2 ثانية)
        osdHideTimer.restart();
    }

    // دالة الفحص التلقائي للإغلاق
    function checkAutoClose() {
        if (!isInteracting && !isHovered) {
            hoverGraceTimer.restart();
        } else {
            hoverGraceTimer.stop();
        }
    }

    // مؤقت 1: فترة السماح عند خروج الماوس (1.5 ثانية)
    Timer {
        id: hoverGraceTimer
        interval: 1500
        repeat: false
        onTriggered: {
            if (!dynamicIsland.isInteracting && !dynamicIsland.isHovered) {
                dynamicIsland.returnToIdle();
            }
        }
    }

    // مؤقت 2: إخفاء OSD الصوت/السطوع (2 ثانية)
    Timer {
        id: osdHideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            // عند الانتهاء، نتأكد مرة أخرى أننا لسنا بصدد استخدام الجزيرة
            checkAutoClose();
        }
    }

    function returnToIdle() {
        // نعود للوضع الافتراضي فقط إذا لم نكن نتفاعل
        if (!isInteracting) {
            dynamicIsland.currentMode = "idle";
        }
    }

    // مراقب لانتهاء التفاعل اليدوي
    onIsInteractingChanged: {
        if (!isInteracting) {
            checkAutoClose();
        } else {
            hoverGraceTimer.stop();
            osdHideTimer.stop();
        }
    }

    // --- الاتصال بالخدمات (تم التحديث لاستخدام الدالة الجديدة) ---

    Connections {
        target: Audio
        function onVolumeChanged() {
            // نرسل طلب إظهار الصوت للدالة المركزية لتقوم بالفحص
            dynamicIsland.showOverlay("volume");
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            dynamicIsland.showOverlay("brightness");
        }
    }

    // --- جسم الجزيرة ---
    Rectangle {
        id: islandRect

        color: "transparent"
        clip: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: ThemeManager.selectedTheme.colors.primary
            }
            GradientStop {
                position: 1.0
                color: ThemeManager.selectedTheme.colors.secondary
            }
        }

        // MouseArea الرئيسية
        MouseArea {
            id: islandMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: false

            onEntered: {
                if (currentMode !== "idle") {
                    dynamicIsland.isHovered = true;
                    hoverGraceTimer.stop();
                    osdHideTimer.stop();
                }
            }

            onExited: {
                dynamicIsland.isHovered = false;
                checkAutoClose();
            }
        }

        // --- الحالات ---
        state: currentMode

        states: [
            State {
                name: "idle"
                PropertyChanges {
                    target: islandRect
                    width: clockText.width + 40
                    height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    anchors.topMargin: 5
                }
                PropertyChanges {
                    target: clockContainer
                    opacity: 1
                }
                PropertyChanges {
                    target: volumeContainer
                    opacity: 0
                }
                PropertyChanges {
                    target: brightnessContainer
                    opacity: 0
                }
            },
            State {
                name: "volume"
                PropertyChanges {
                    target: islandRect
                    width: 300
                    height: 60
                    // radius: 30
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    anchors.topMargin: dynamicIsland.dropDistance + 10
                }
                PropertyChanges {
                    target: clockContainer
                    opacity: 0
                }
                PropertyChanges {
                    target: volumeContainer
                    opacity: 1
                }
                PropertyChanges {
                    target: brightnessContainer
                    opacity: 0
                }
            },
            State {
                name: "brightness"
                PropertyChanges {
                    target: islandRect
                    width: 300
                    height: 60
                    // radius: 30
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    anchors.topMargin: dynamicIsland.dropDistance + 10
                }
                PropertyChanges {
                    target: clockContainer
                    opacity: 0
                }
                PropertyChanges {
                    target: volumeContainer
                    opacity: 0
                }
                PropertyChanges {
                    target: brightnessContainer
                    opacity: 1
                }
            }
        ]

        transitions: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "anchors.topMargin"
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    properties: "width, height"
                    duration: 400
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "radius"
                    duration: 400
                }
                NumberAnimation {
                    targets: [clockContainer, volumeContainer, brightnessContainer]
                    property: "opacity"
                    duration: 200
                }
            }
        }

        // --- المحتويات ---

        // 1. الساعة
        Item {
            id: clockContainer
            anchors.centerIn: parent
            width: clockText.width
            height: parent.height
            visible: opacity > 0
            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }
            Text {
                id: clockText
                text: clock.date.toLocaleString(Qt.locale(), "hh:mm AP - dddd, dd MMMM yyyy")
                font.bold: true
                color: ThemeManager.selectedTheme.colors.onPrimary
                anchors.centerIn: parent
                verticalAlignment: Text.AlignVCenter
            }
        }

        // 2. الصوت
        Item {
            id: volumeContainer
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            anchors.bottomMargin: 8
            visible: opacity > 0

            SystemControlWidget {
                id: volWidget
                anchors.fill: parent
                value: Audio.volume
                accentColor: ThemeManager.selectedTheme.colors.onPrimary

                onPressedChanged: dynamicIsland.isInteracting = pressed

                icon: {
                    if (Audio.muted)
                        return "";
                    if (value < 0.30)
                        return "";
                    if (value < 0.70)
                        return "";
                    return "";
                }

                onUserChangedValue: v => Audio.setVolume(v)
            }
        }

        // 3. السطوع
        Item {
            id: brightnessContainer
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            anchors.bottomMargin: 8

            visible: opacity > 0

            SystemControlWidget {
                id: briWidget
                anchors.fill: parent
                value: Brightness.brightness
                accentColor: ThemeManager.selectedTheme.colors.onPrimary

                onPressedChanged: dynamicIsland.isInteracting = pressed

                icon: {
                    if (value < 0.30)
                        return "󰃞";
                    if (value < 0.70)
                        return "󰃟";
                    return "󰃠";
                }

                onUserChangedValue: v => {
                    const mon = Brightness.getMonitorForScreen();
                    if (mon)
                        mon.setBrightness(v);
                }
            }
        }
    }
}

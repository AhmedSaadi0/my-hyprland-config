// components/TopbarCircularProgress.qml

import QtQuick
import Quickshell.Io
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

CircularProgress {
    id: root

    width: 22
    height: 20

    value: 0.0

    inverted: true
    rounded: true

    backgroundColor: palette.accent.alpha(0.4)
    foregroundColor: palette.accent

    // توحيد التحكم: نستخدم activeProcess فقط للتحكم في التشغيل
    property bool activeProcess: true

    property string icon: ""
    property string iconFontFamily: "FantasqueSansM Nerd Font Propo"
    property int iconFontSize: 11
    property color iconColor: palette.accent
    property var command: []
    property int updateInterval: 1000

    // إبقاء glowIcon كما هو
    property bool glowIcon: false

    property var onReadHandler: function (data) {
        var percent = parseFloat(data);
        if (!isNaN(percent)) {
            root.value = percent / 100.0;
        } else {
            console.warn("ReusableCpuCircularProgress: onReadHandler received non-numeric data:", data);
        }
    }

    Text {
        id: textitem
        // الأحجام كما هي
        width: 20
        height: 30
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: root.iconFontSize
        font.family: root.iconFontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        z: 2

        // --- التوهج المحسن (ناعم وخفيف) ---
        // Glow {
        //     id: iconGlow
        //     anchors.fill: textitem
        //     source: textitem
        //
        //     // التعديلات هنا:
        //     radius: 5          // تصغير الحجم ليتناسب مع الأيقونة الصغيرة
        //     samples: 10        // دقة التنعيم
        //     spread: 0.1        // قيمة قليلة تجعل التوهج ينتشر بنعومة (ليس حاداً)
        //     color: "yellow"    // يمكنك تغييره لـ palette.accent ليتناسق مع الثيم
        //     transparentBorder: true
        //
        //     visible: root.glowIcon
        //     z: -1 // خلف النص
        //
        //     // أنميشن هادئ جداً
        //     SequentialAnimation on opacity {
        //         running: root.glowIcon
        //         loops: Animation.Infinite
        //         alwaysRunToEnd: true
        //
        //         // التوهج يتنفس بين شبه مخفي (0.1) ومتوسط (0.6)
        //         // لا يصل أبداً لـ 1.0 لتجنب "حرق" العين
        //         NumberAnimation {
        //             to: 0.6
        //             duration: 1200
        //             easing.type: Easing.InOutSine
        //         }
        //         NumberAnimation {
        //             to: 0.1
        //             duration: 1200
        //             easing.type: Easing.InOutSine
        //         }
        //     }
        // }

        // MouseArea {
        //     id: _mouseArea
        //     anchors.fill: parent
        //     hoverEnabled: true
        // }
        //
        // ToolTip {
        //     visible: _mouseArea.containsMouse
        //     delay: 500
        //     text: Math.round(root.value * 100) + "%"
        //
        //     contentItem: Text {
        //         text: parent.text
        //         color: root.iconColor
        //         font.pixelSize: 12
        //     }
        //     background: Rectangle {
        //         color: palette.window
        //         border.color: palette.mid
        //         radius: 4
        //     }
        // }
    }

    Process {
        id: processId
        command: root.command
        running: root.activeProcess // ربط مباشر بـ activeProcess

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
        running: root.activeProcess // يعمل طالما العملية نشطة

        onTriggered: {
            // إعادة تفعيل العملية لجلب بيانات جديدة
            processId.running = false;
            processId.running = true;
        }
    }

    // تنظيف عند التدمير
    Component.onDestruction: {
        updateTimer.stop();
        processId.running = false;
    }
}

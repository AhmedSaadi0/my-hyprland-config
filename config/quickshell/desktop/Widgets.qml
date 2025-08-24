// desktop/Widgets.qml (الإصدار النهائي والكامل)

import QtQuick
import Quickshell
import QtQuick.Effects

import "root:/themes"
import "root:/components"

PanelWindow {
    id: desktopRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    aboveWindows: false
    focusable: true
    exclusionMode: ExclusionMode.Ignore

    // خاصية لتخزين مسار الصورة الجديد مؤقتًا
    property string nextImageSource: ThemeManager.selectedTheme.desktopClock.depthOverlayPath

    ClockWidget {}

    Image {
        id: foregroundImage
        z: 2
        opacity: 1 // تبدأ الصورة مرئية بالكامل

        visible: ThemeManager.selectedTheme.desktopClock.depthEffectEnabled
        source: ThemeManager.selectedTheme.desktopClock.depthOverlayPath

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        // أنميشن للتلاشي عند تغيير الشفافية
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            } // مدة أنميشن التلاشي 500 ميلي ثانية
        }

        Timer {
            id: imageChangeTimer
            interval: 800 // 800 ميلي ثانية تأخير
            repeat: false
            onTriggered: {
                // عند انتهاء المؤقت، نبدأ عملية التغيير مع الأنميشن
                // أولاً، نجعل الصورة الحالية شفافة
                foregroundImage.opacity = 0;
            }
        }

        // مراقبة التغيير في مسار الصورة
        Connections {
            target: ThemeManager.selectedTheme.desktopClock
            function onDepthOverlayPathChanged() {
                // نخزن المصدر الجديد ونبدأ المؤقت
                nextImageSource = ThemeManager.selectedTheme.desktopClock.depthOverlayPath;
                imageChangeTimer.restart();
            }
        }

        // عندما ينتهي أنميشن التلاشي للخارج (تصبح الصورة شفافة)
        onOpacityChanged: {
            // إذا كانت الصورة قد أصبحت شفافة تمامًا ومصدرها لا يطابق المصدر الجديد
            if (foregroundImage.opacity === 0 && foregroundImage.source !== nextImageSource) {
                // نغير المصدر إلى الصورة الجديدة
                foregroundImage.source = nextImageSource;
                // ثم نعيد الشفافية إلى 1 لتبدأ الصورة الجديدة في الظهور (أنميشن التلاشي للداخل)
                foregroundImage.opacity = 1;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onPressed: {
            if (clockComponent.editMode) {
                clockComponent.editMode = false;
            }
            mouse.accepted = false;
        }
    }
}

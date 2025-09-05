import QtQuick
import Quickshell

import "root:/themes" as Theme
import "root:/components"

// TODO: -> Improve this code
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

    readonly property var clockSettings: Theme.ThemeManager.selectedTheme.desktopClock

    readonly property point themeClockPosition: clockSettings.position
    readonly property size themeClockSize: clockSettings.size

    property point currentClockPosition
    property size currentClockSize

    Component.onCompleted: {
        currentClockPosition = themeClockPosition;
        currentClockSize = themeClockSize;
    }

    Connections {
        target: Theme.ThemeManager
        function onSelectedThemeUpdated() {
            console.log("Theme updated. Resetting clock position and size.");
            currentClockPosition = themeClockPosition;
            currentClockSize = themeClockSize;
        }
    }

    DesktopClock {
        id: theClock

        position: desktopRoot.currentClockPosition
        size: desktopRoot.currentClockSize
        editMode: false

        clockColor: clockSettings.useThemeColor ? Theme.ThemeManager.selectedTheme.colors.primary : clockSettings.color
        clockFont: clockSettings.font
        clockFormat: clockSettings.format
        clockLocale: clockSettings.local
        enableAnimation: clockSettings.enableAnimation
        shadowEnabled: clockSettings.shadowEnabled
        shadowColor: clockSettings.shadowColor

        onRequestNewGeometry: (newPosition, newSize) => {
            currentClockPosition = newPosition;
            currentClockSize = newSize;
        }

        onEditModeChanged: {
            if (!editMode) {
                console.log("Edit mode finished. Saving geometry.");
                Theme.ThemeManager.updateAndApplyTheme({
                    "_desktopClockPosition": currentClockPosition,
                    "_desktopClockSize": currentClockSize
                }, true);
            }
        }
    }

    Image {
        id: foregroundImage
        z: 2
        opacity: 1

        visible: clockSettings.depthEffectEnabled
        source: clockSettings.depthEffectEnabled ? clockSettings.depthOverlayPath : ""

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        // onOpacityChanged: {
        //     if (opacity === 0 && clockSettings.depthEffectEnabled) {
        //         console.log("Opacity is 0. Updating image source and making it visible again.");
        //
        //         // 1. تحديث المصدر (إذا كان مختلفًا)
        //         if (source !== clockSettings.depthOverlayPath) {
        //             source = clockSettings.depthOverlayPath;
        //         }
        //
        //         // 2. إعادة إظهار الصورة فورًا
        //         opacity = 1;
        //     }
        // }
    }

    MouseArea {
        anchors.fill: parent
        z: -1 // تأكد من أنه خلف الساعة
        onPressed: {
            // إذا كانت الساعة في وضع التعديل، قم بإلغائه
            if (theClock.editMode) {
                theClock.editMode = false;
            }
        }
    }
}

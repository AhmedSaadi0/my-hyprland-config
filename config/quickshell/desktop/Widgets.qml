import QtQuick
import Quickshell

import "root:/themes" as Theme
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

    readonly property var clockSettings: Theme.ThemeManager.selectedTheme.desktopClock

    // property point currentClockPosition: clockSettings.position
    // property size currentClockSize: clockSettings.size

    property point currentClockPosition
    property size currentClockSize

    // قم بتهيئتها مرة واحدة عند اكتمال تحميل المكون
    Component.onCompleted: {
        currentClockPosition = clockSettings.position;
        currentClockSize = clockSettings.size;
    }

    DesktopClock {
        id: theClock

        clockPosition: currentClockPosition
        clockSize: currentClockSize

        visible: clockSettings.enabled
        editMode: false
        clockColor: clockSettings.useThemeColor ? Theme.ThemeManager.selectedTheme.colors.primary : clockSettings.color
        clockFont: clockSettings.font
        clockFormat: clockSettings.format
        clockLocale: clockSettings.local
        shadowEnabled: clockSettings.shadowEnabled
        shadowColor: clockSettings.shadowColor

        onEditModeToggled: (editing, newPosition, newSize) => {
            if (!editing) {
                const updatedData = {
                    "_desktopClockPosition": newPosition,
                    "_desktopClockSize": newSize
                };
                Theme.ThemeManager.updateAndApplyTheme(updatedData, true);
                theClock.playSaveFeedbackAnimation();
            }
        }
    }

    Connections {
        target: Theme.ThemeManager
        function onSelectedThemeUpdated() {
            currentClockPosition = clockSettings.position;
            currentClockSize = clockSettings.size;
            foregroundImage.opacity = 0;
        }
    }

    Image {
        id: foregroundImage
        z: 2
        opacity: 1

        visible: clockSettings.depthEffectEnabled

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }

        onOpacityChanged: {
            if (foregroundImage.opacity === 0 && foregroundImage.source !== clockSettings.depthOverlayPath) {
                foregroundImage.source = clockSettings.depthOverlayPath;
                foregroundImage.opacity = 1;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onPressed: {
            if (theClock.editMode) {
                theClock.editMode = false;
            }
            mouse.accepted = false;
        }
    }
}

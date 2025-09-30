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

    // Conditional properties - only valid when clock is enabled
    readonly property point themeClockPosition: clockSettings?.enabled ? clockSettings.position : Qt.point(0, 0)
    readonly property size themeClockSize: clockSettings?.enabled ? clockSettings.size : Qt.size(0, 0)

    property point currentClockPosition: themeClockPosition
    property size currentClockSize: themeClockSize

    // Dynamic clock creation/destruction based on enabled property
    Loader {
        id: clockLoader
        active: clockSettings?.enabled || false
        sourceComponent: clockComponent

        onLoaded: {
            // Initialize position and size when clock is created
            desktopRoot.currentClockPosition = desktopRoot.themeClockPosition;
            desktopRoot.currentClockSize = desktopRoot.themeClockSize;
        }
    }

    Component {
        id: clockComponent

        DesktopClock {
            id: theClock

            position: desktopRoot.currentClockPosition
            size: desktopRoot.currentClockSize
            editMode: false

            // Safe property access with fallbacks
            clockColor: clockSettings?.useThemeColor ? Theme.ThemeManager.selectedTheme.colors.primary : (clockSettings?.color || "white")
            clockFont: clockSettings?.font || "Arial"
            clockFormat: clockSettings?.format || "hh:mm:ss"
            clockLocale: clockSettings?.local || "en_US"
            enableAnimation: clockSettings?.enableAnimation || false
            shadowEnabled: clockSettings?.shadowEnabled || false
            shadowColor: clockSettings?.shadowColor || "black"

            onRequestNewGeometry: (newPosition, newSize) => {
                desktopRoot.currentClockPosition = newPosition;
                desktopRoot.currentClockSize = newSize;
            }

            onEditModeChanged: {
                if (!editMode) {
                    console.log("Edit mode finished. Saving geometry.");
                    Theme.ThemeManager.updateAndApplyTheme({
                        "_desktopClockPosition": desktopRoot.currentClockPosition,
                        "_desktopClockSize": desktopRoot.currentClockSize
                    }, true);
                }
            }
        }
    }

    Image {
        id: foregroundImage
        z: 2
        opacity: 1

        // Only show depth effect if clock is enabled AND depth effect is enabled
        visible: (clockSettings?.enabled && clockSettings?.depthEffectEnabled) || false
        enabled: visible
        source: visible ? (clockSettings?.depthOverlayPath || "") : ""

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onPressed: {
            // Only handle click if clock is loaded and in edit mode
            if (clockLoader.item?.editMode) {
                clockLoader.item.editMode = false;
            }
        }
    }

    Connections {
        target: Theme.ThemeManager

        function onSelectedThemeUpdated() {
            console.log("Theme updated. Resetting clock position and size.");

            // Only update if clock is enabled
            if (clockSettings?.enabled) {
                desktopRoot.currentClockPosition = desktopRoot.themeClockPosition;
                desktopRoot.currentClockSize = desktopRoot.themeClockSize;
            }
        }
    }
}

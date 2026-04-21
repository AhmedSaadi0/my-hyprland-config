// bars/systemtray/TrayItem.qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "root:/themes"
import "root:/config"
import "root:/utils"

MouseArea {
    id: root

    required property SystemTrayItem modelData

    implicitWidth: ThemeManager.selectedTheme.dimensions.barWidgetsHeight - 6
    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    readonly property string currentIconTheme: (ThemeManager.selectedTheme && ThemeManager.selectedTheme.systemSettings) ? ThemeManager.selectedTheme.systemSettings.themeIcons : ""
    readonly property bool needsAttention: modelData.status === Status.NeedsAttention
    property string resolvedIconSource: ""
    property bool pendingResolve: false
    property string lastIconValue: ""
    property string lastRequestedIconKey: ""

    function requestIconResolve() {
        iconResolveDebounce.restart();
    }

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onModelDataChanged: requestIconResolve()

    Connections {
        target: modelData
        function onIconChanged() {
            requestIconResolve();
        }
    }

    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
            requestIconResolve();
        }
    }

    Component.onCompleted: requestIconResolve()

    Timer {
        id: iconResolveDebounce
        interval: 180
        repeat: false
        onTriggered: {
            const iconValue = String(modelData.icon || "");
            root.lastIconValue = iconValue;
            console.info("[TrayItem] resolve requested. title:", modelData.title, "iconValue:", iconValue, "theme:", currentIconTheme);
            if (iconValue === "") {
                resolvedIconSource = "";
                console.info("[TrayItem] empty iconValue -> resolvedIconSource cleared");
                return;
            }

            const hasTheme = currentIconTheme && currentIconTheme !== "";
            const isDirect = Helper.isDirectImageSource(iconValue);

            let iconKey = "";
            if (isDirect) {
                if (hasTheme)
                    iconKey = Helper.iconNameFromPath(iconValue);
                if (!hasTheme || iconKey === "") {
                    resolvedIconSource = Helper.toImageSource(iconValue);
                    console.info("[TrayItem] direct icon used. hasTheme:", hasTheme, "iconKey:", iconKey, "resolved:", resolvedIconSource);
                    return;
                }
            } else {
                iconKey = iconValue;
            }

            if (!hasTheme) {
                resolvedIconSource = Helper.toImageSource(Quickshell.iconPath(iconKey, "application-x-executable"));
                console.info("[TrayItem] no theme. fallback iconPath:", iconKey, "resolved:", resolvedIconSource);
                return;
            }

            if (themeIconResolver.running) {
                pendingResolve = true;
                console.info("[TrayItem] resolver busy -> pendingResolve");
                return;
            }

            root.lastRequestedIconKey = iconKey;
            console.info("[TrayItem] resolver start. iconKey:", iconKey);
            themeIconResolver.command = [App.pythonPath, App.pythonScriptsPath + "/resolve_theme_icons.py", "--theme", currentIconTheme, "--icons-json", JSON.stringify([iconKey, "application-x-executable"])];
            themeIconResolver.running = true;
        }
    }

    Process {
        id: themeIconResolver
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const iconValue = root.lastIconValue || "";
                const iconKey = root.lastRequestedIconKey || "";
                try {
                    const parsed = JSON.parse(this.text.toString());
                    const picked = (iconKey && parsed[iconKey]) ? parsed[iconKey] : (parsed["application-x-executable"] || "");
                    if (picked !== "") {
                        resolvedIconSource = Helper.toImageSource(picked);
                        console.info("[TrayItem] resolver OK. iconKey:", iconKey, "picked:", picked, "resolved:", resolvedIconSource);
                    } else if (Helper.isDirectImageSource(iconValue)) {
                        resolvedIconSource = Helper.toImageSource(iconValue);
                        console.info("[TrayItem] resolver empty -> direct icon used. iconValue:", iconValue, "resolved:", resolvedIconSource);
                    } else {
                        resolvedIconSource = Helper.toImageSource(Quickshell.iconPath(iconKey || iconValue, "application-x-executable"));
                        console.info("[TrayItem] resolver empty -> iconPath fallback. iconKey:", iconKey, "iconValue:", iconValue, "resolved:", resolvedIconSource);
                    }
                } catch (e) {
                    console.warn("[TrayItem] Failed to parse icon resolver JSON:", e);
                    resolvedIconSource = Helper.isDirectImageSource(iconValue) ? Helper.toImageSource(iconValue) : Helper.toImageSource(Quickshell.iconPath(iconKey || iconValue, "application-x-executable"));
                    console.info("[TrayItem] resolver JSON parse error -> fallback. iconKey:", iconKey, "iconValue:", iconValue, "resolved:", resolvedIconSource);
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            void exitStatus;
            if (exitCode !== 0) {
                const iconValue = root.lastIconValue || "";
                const iconKey = root.lastRequestedIconKey || "";
                resolvedIconSource = Helper.isDirectImageSource(iconValue) ? Helper.toImageSource(iconValue) : Helper.toImageSource(Quickshell.iconPath(iconKey || iconValue, "application-x-executable"));
                console.info("[TrayItem] resolver exited with code:", exitCode, "iconKey:", iconKey, "iconValue:", iconValue, "resolved:", resolvedIconSource);
            }
        }

        onRunningChanged: {
            if (!running && pendingResolve) {
                pendingResolve = false;
                iconResolveDebounce.restart();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: needsAttention ? ThemeManager.selectedTheme.colors.warning : ThemeManager.selectedTheme.colors.primary
        opacity: root.containsPress ? 0.30 : (root.containsMouse ? 0.14 : (needsAttention ? 0.12 : 0))
        border.width: needsAttention ? 1 : 0
        border.color: needsAttention ? ThemeManager.selectedTheme.colors.warning : "transparent"

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (modelData.hasMenu) {
            menu.open();
        }
    }

    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.window: root.QsWindow.window
    }

    Rectangle {
        id: iconPlate
        anchors.centerIn: parent
        width: parent.implicitHeight - 2
        height: parent.implicitHeight - 2
        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 1.6
        color: root.containsPress ? ThemeManager.selectedTheme.colors.topbarBgColorV2 : "transparent"
        border.width: root.containsMouse ? 1 : 0
        border.color: ThemeManager.selectedTheme.colors.topbarFgColorV2.alpha(0.22)

        IconImage {
            id: trayIcon
            anchors.centerIn: parent
            width: parent.width - 7
            height: parent.height - 7
            source: root.resolvedIconSource
            asynchronous: true
            mipmap: true
            smooth: true
        }
    }

    Rectangle {
        id: tooltip
        visible: root.containsMouse && (modelData.tooltipTitle !== "" || modelData.tooltipDescription !== "" || modelData.title !== "")

        anchors.bottom: parent.top
        anchors.bottomMargin: ThemeManager.selectedTheme.dimensions.spacingMedium
        anchors.horizontalCenter: parent.horizontalCenter

        width: tooltipText.width + (ThemeManager.selectedTheme.dimensions.spacingMedium * 2)
        height: tooltipText.height + ThemeManager.selectedTheme.dimensions.spacingSmall
        z: 100

        color: ThemeManager.selectedTheme.colors.topbarColor
        border.color: ThemeManager.selectedTheme.colors.primary
        border.width: 1
        radius: ThemeManager.selectedTheme.dimensions.elementRadius / 4

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: (modelData.tooltipTitle || modelData.title || modelData.tooltipDescription || "")
            color: ThemeManager.selectedTheme.colors.topbarFgColor
            font.family: ThemeManager.selectedTheme.typography.bodyFont
            font.pixelSize: ThemeManager.selectedTheme.typography.small
        }

        opacity: visible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }
}

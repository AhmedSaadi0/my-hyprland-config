// components/DockItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:/themes"
import "root:/config"
import "root:/utils"
import "root:/services"

Item {
    id: itemRoot

    required property string appId
    required property var appData
    required property bool isRunning
    required property string windowAddress
    required property int instanceCount
    required property bool isPinnedToDock
    required property string tooltipText
    required property int iconSize
    required property var windows

    required property var panelWindow

    readonly property bool isFavorite: App.favoriteApps.indexOf(appId) !== -1

    width: iconSize + 16
    height: iconSize + 16

    readonly property bool hovered: mouseArea.containsMouse

    function launchOrFocus() {
        if (isRunning && windowAddress) {
            Hyprland.dispatch("focuswindow address:" + windowAddress);
        } else if (appData && typeof appData.execute === "function") {
            appData.execute();
        } else if (appId) {
            let cleanCmd = appId.endsWith(".desktop") ? appId.slice(0, -8) : appId;
            Qt.openUrlExternally("bin/" + cleanCmd);
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.8
        color: hovered ? ThemeManager.selectedTheme.colors.primary.alpha(0.12) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // --- أيقونة التطبيق (محدثة لتستدعي خدمة الأيقونات المركزية) ---
    IconImage {
        id: icon
        anchors.centerIn: parent
        width: iconSize
        height: iconSize

        source: {
            let trigger = IconService.iconUpdateTrigger;
            let iconKey = appData ? appData.icon : "application-x-executable";
            return IconService.getCached(iconKey);
        }

        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    Rectangle {
        id: activeDot
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        width: isRunning ? (hovered ? 12 : 5) : 0
        height: 5
        radius: 2.5
        color: ThemeManager.selectedTheme.colors.primary

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        width: 16
        height: 16
        radius: 8
        color: ThemeManager.selectedTheme.colors.error
        visible: isRunning && instanceCount > 1

        Text {
            anchors.centerIn: parent
            text: instanceCount
            font.pixelSize: 10
            font.bold: true
            color: ThemeManager.selectedTheme.colors.onError
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onContainsMouseChanged: {
            if (containsMouse) {
                tooltipDelay.restart();
            } else {
                tooltipDelay.stop();
                if (!tooltipHoverHandler.hovered) {
                    hideTooltipTimer.restart();
                }
            }
        }

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                bounceAnim.restart();
                itemRoot.launchOrFocus();
            } else if (mouse.button === Qt.RightButton) {
                if (contextMenu.opened) {
                    contextMenu.close();
                    if (panelWindow) {
                        panelWindow.anyMenuOpen = false;
                        if (panelWindow.currentOpenPopup === contextMenu) {
                            panelWindow.currentOpenPopup = null;
                        }
                    }
                } else {
                    if (panelWindow.currentOpenPopup && panelWindow.currentOpenPopup !== contextMenu) {
                        panelWindow.currentOpenPopup.close();
                    }
                    contextMenu.open();
                }
            }
        }
    }

    Timer {
        id: tooltipDelay
        interval: 250
        onTriggered: {
            if (mouseArea.containsMouse && !contextMenu.opened) {
                tooltip.opacity = 1;
                if (panelWindow)
                    panelWindow.anyDockTooltipVisible = true;
            }
        }
    }

    Timer {
        id: hideTooltipTimer
        interval: 100
        onTriggered: {
            if (!mouseArea.containsMouse && !tooltipHoverHandler.hovered) {
                tooltip.opacity = 0;
                if (panelWindow)
                    panelWindow.anyDockTooltipVisible = false;
            }
        }
    }

    Rectangle {
        id: tooltip
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height - 10
        width: instanceCount > 1 ? instanceListRow.width + 16 : tooltipLabel.implicitWidth + 16
        height: instanceCount > 1 ? instanceListRow.height + 12 : tooltipLabel.implicitHeight + 10
        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
        color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
        border.color: ThemeManager.selectedTheme.colors.outlineVariant
        border.width: 1
        opacity: 0
        visible: opacity > 0
        z: 100

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        HoverHandler {
            id: tooltipHoverHandler
            onHoveredChanged: {
                if (!hovered && !mouseArea.containsMouse) {
                    hideTooltipTimer.restart();
                }
            }
        }

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            visible: instanceCount <= 1
            text: appData ? appData.name : appId
            font.pixelSize: 11
            color: ThemeManager.selectedTheme.colors.onSurface
        }

        Row {
            id: instanceListRow
            visible: instanceCount > 1
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: instanceCount > 1 ? windows : []
                delegate: Item {
                    width: 32
                    height: 32

                    Rectangle {
                        anchors.fill: parent
                        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.5
                        color: instanceMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : ThemeManager.selectedTheme.colors.surfaceContainerHigh
                    }

                    // أيقونة النوافذ المنبثقة المتعددة
                    IconImage {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: {
                            let trigger = IconService.iconUpdateTrigger;
                            let iconKey = appData ? appData.icon : "application-x-executable";
                            return IconService.getCached(iconKey);
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 14
                        height: 11
                        radius: 3
                        color: ThemeManager.selectedTheme.colors.primary

                        Text {
                            anchors.centerIn: parent
                            text: (modelData && modelData.workspaceId >= 0) ? modelData.workspaceId : "?"
                            font.pixelSize: 8
                            font.bold: true
                            color: ThemeManager.selectedTheme.colors.onPrimary
                        }
                    }

                    MouseArea {
                        id: instanceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData && modelData.address) {
                                Hyprland.dispatch("focuswindow address:" + modelData.address);
                            }
                            tooltip.opacity = 0;
                            tooltipDelay.stop();
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: contextMenu
        width: 200
        padding: 6
        closePolicy: Popup.CloseOnEscape

        y: -height - 8
        x: (parent.width / 2) - (width / 2)

        onOpened: {
            tooltip.opacity = 0;
            tooltipDelay.stop();
            hideTooltipTimer.stop();
            if (panelWindow) {
                panelWindow.anyDockTooltipVisible = false;
                panelWindow.anyMenuOpen = true;
                panelWindow.currentOpenPopup = contextMenu;
            }
        }

        onClosed: {
            if (panelWindow) {
                panelWindow.anyMenuOpen = false;
                if (panelWindow.currentOpenPopup === contextMenu) {
                    panelWindow.currentOpenPopup = null;
                }
            }
        }

        background: Rectangle {
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
            border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 4
            focus: true
            Keys.onEscapePressed: contextMenu.close()

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: openMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: isRunning ? "󰇄" : "󰐊"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }
                    Text {
                        text: isRunning ? qsTr("Focus") : qsTr("Open")
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurface
                    }
                }

                MouseArea {
                    id: openMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close();
                        if (panelWindow) {
                            panelWindow.anyMenuOpen = false;
                            if (panelWindow.currentOpenPopup === contextMenu) {
                                panelWindow.currentOpenPopup = null;
                            }
                        }
                        itemRoot.launchOrFocus();
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: openNewMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"
                visible: isRunning

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "󰐕"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }
                    Text {
                        text: qsTr("New Window")
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurface
                    }
                }

                MouseArea {
                    id: openNewMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close();
                        if (panelWindow) {
                            panelWindow.anyMenuOpen = false;
                            if (panelWindow.currentOpenPopup === contextMenu) {
                                panelWindow.currentOpenPopup = null;
                            }
                        }
                        bounceAnim.restart();
                        if (appData && typeof appData.execute === "function") {
                            appData.execute();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: closeMouse.containsMouse ? ThemeManager.selectedTheme.colors.error.alpha(0.15) : "transparent"
                visible: isRunning

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "󰅙"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.error
                    }
                    Text {
                        text: qsTr("Close")
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.error
                    }
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close();
                        if (panelWindow) {
                            panelWindow.anyMenuOpen = false;
                            if (panelWindow.currentOpenPopup === contextMenu) {
                                panelWindow.currentOpenPopup = null;
                            }
                        }
                        if (windowAddress) {
                            Hyprland.dispatch("closewindow address:" + windowAddress);
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: favMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "󰓎"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: isFavorite ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }
                    Text {
                        text: isFavorite ? qsTr("Remove from favorites") : qsTr("Add to favorites")
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurface
                    }
                }

                MouseArea {
                    id: favMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close();
                        if (panelWindow) {
                            panelWindow.anyMenuOpen = false;
                            if (panelWindow.currentOpenPopup === contextMenu) {
                                panelWindow.currentOpenPopup = null;
                            }
                        }
                        let favs = [...App.favoriteApps];
                        let idx = favs.indexOf(appId);
                        if (idx >= 0) {
                            favs.splice(idx, 1);
                        } else {
                            favs.push(appId);
                        }
                        App.favoriteApps = favs;
                        App.updateConfig("favoriteApps", App.favoriteApps);
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: pinMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "󰋜"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: isPinnedToDock ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }
                    Text {
                        text: isPinnedToDock ? qsTr("Unpin from Dock") : qsTr("Pin to Dock")
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurface
                    }
                }

                MouseArea {
                    id: pinMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close();
                        if (panelWindow) {
                            panelWindow.anyMenuOpen = false;
                            if (panelWindow.currentOpenPopup === contextMenu) {
                                panelWindow.currentOpenPopup = null;
                            }
                        }
                        let dockApps = [...App.dockApps];
                        let idx = dockApps.indexOf(appId);
                        if (idx >= 0) {
                            dockApps.splice(idx, 1);
                        } else {
                            dockApps.push(appId);
                        }
                        App.dockApps = dockApps;
                        App.updateConfig("dockApps", App.dockApps);
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: bounceAnim
        running: false

        PropertyAnimation {
            target: icon
            property: "scale"
            to: 0.85
            duration: 80
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 1.15
            duration: 100
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 1.0
            duration: 80
            easing.type: Easing.OutQuad
        }
    }
}

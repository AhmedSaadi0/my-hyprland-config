import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "root:/themes"
import "root:/services"

PanelWindow {
    id: root

    // required property ShellScreen modelData
    // screen: modelData
    property bool matchesScreen: OverlayService.targetScreenName === "" || OverlayService.targetScreenName === modelData.name
    property bool overlayActive: false
    property bool showImage: false
    property bool revealImageWhenReady: false
    property real panelProgress: OverlayService.visible && matchesScreen ? 1 : 0
    property real imageProgress: showImage ? 1 : 0
    property real fullImageBlend: showImage && !sameImageSource && fullImage.status === Image.Ready ? 1 : 0
    readonly property bool sameImageSource: OverlayService.imagePreviewSource === OverlayService.imageFullSource
    readonly property bool previewReady: previewImage.status === Image.Ready
    readonly property bool fullReady: fullImage.status === Image.Ready
    readonly property bool anyImageReady: previewReady || fullReady

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    color: "transparent"
    aboveWindows: true
    focusable: overlayActive
    exclusionMode: ExclusionMode.Ignore
    visible: overlayActive

    WlrLayershell.namespace: "NibrasShell:overlay-preview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Component.onCompleted: {
        console.info("OverlayWindow Completed ");
    }

    function closeOverlay() {
        OverlayService.close();
    }

    onVisibleChanged: {
        console.info("[OverlayWindow]", modelData.name, "visible:", visible, "target:", OverlayService.targetScreenName);
    }

    function prepareOpen() {
        if (!matchesScreen)
            return;

        closeCommitTimer.stop();
        overlayActive = true;
        showImage = false;
        revealImageWhenReady = false;
        imageRevealDelay.restart();
    }

    function revealImageIfPossible() {
        if (!OverlayService.visible || !matchesScreen)
            return;
        if (!revealImageWhenReady || !anyImageReady)
            return;

        showImage = true;
        revealImageWhenReady = false;
    }

    function beginClose() {
        imageRevealDelay.stop();
        revealImageWhenReady = false;
        showImage = false;
        closeCommitTimer.restart();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.closeOverlay();
            event.accepted = true;
        }
    }

    Connections {
        target: OverlayService

        function onVisibleChanged() {
            if (OverlayService.visible) {
                root.prepareOpen();
            } else {
                root.beginClose();
            }
        }

        function onTargetScreenNameChanged() {
            if (OverlayService.visible) {
                root.prepareOpen();
            } else {
                root.beginClose();
            }
        }
    }

    onMatchesScreenChanged: {
        if (OverlayService.visible) {
            prepareOpen();
        } else if (overlayActive) {
            beginClose();
        }
    }

    Behavior on panelProgress {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on imageProgress {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Behavior on fullImageBlend {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: imageRevealDelay
        interval: 300
        repeat: false
        onTriggered: {
            root.revealImageWhenReady = true;
            root.revealImageIfPossible();
        }
    }

    Timer {
        id: closeCommitTimer
        interval: 190
        repeat: false
        onTriggered: {
            if (!OverlayService.visible || !root.matchesScreen)
                root.overlayActive = false;
        }
    }

    Item {
        id: keyboardCapture
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.closeOverlay();
                event.accepted = true;
            }
        }

        Item {
            anchors.fill: parent

Rectangle {
                anchors.fill: parent
                color: "#dd000000"
                opacity: panelProgress
            }

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeOverlay()
        }

        Item {
            id: previewShell
            anchors.fill: parent
            anchors.margins: 24
            opacity: panelProgress
            scale: 0.985 + (panelProgress * 0.015)

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => mouse.accepted = true
            }

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: ThemeManager.selectedTheme.colors.leftMenuBgColorV1.alpha(0.55)
                border.width: 1
                border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.22)
            }

            Item {
                id: imageFrame
                anchors.fill: parent
                anchors.margins: 20

                Image {
                    id: previewImage
                    anchors.fill: parent
                    source: OverlayService.imagePreviewSource
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    sourceSize.width: Math.max(root.width, 1)
                    sourceSize.height: Math.max(root.height, 1)
                    opacity: {
                        if (!root.showImage || !root.previewReady)
                            return 0;
                        if (root.sameImageSource)
                            return root.imageProgress;
                        return root.imageProgress * (1 - root.fullImageBlend);
                    }
                    scale: 1.01 - (root.imageProgress * 0.01)

                    onStatusChanged: root.revealImageIfPossible()
                }

                Image {
                    id: fullImage
                    anchors.fill: parent
                    source: OverlayService.imageFullSource
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    sourceSize.width: Math.max(root.width, 1)
                    sourceSize.height: Math.max(root.height, 1)
                    visible: !root.sameImageSource
                    opacity: root.showImage && root.fullReady ? root.imageProgress * root.fullImageBlend : 0
                    scale: 1.012 - (root.imageProgress * 0.012)

                    onStatusChanged: {
                        root.revealImageIfPossible();
                        if (status === Image.Ready) {
                            console.info("[OverlayWindow]", modelData.name, "full image ready");
                        }
                    }
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: panelProgress > 0.2 && !root.showImage
                    width: 64
                    height: 64
                    opacity: running ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 16
                visible: OverlayService.imageTitle !== ""
                radius: 6
                color: "#7a000000"
                border.width: 1
                border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.24)
                width: Math.min(titleText.implicitWidth + 20, parent.width * 0.45)
                height: titleText.implicitHeight + 14
                opacity: imageProgress

                Text {
                    id: titleText
                    anchors.fill: parent
                    anchors.margins: 10
                    text: OverlayService.imageTitle
                    color: ThemeManager.selectedTheme.colors.topbarFgColor || "white"
                    elide: Text.ElideRight
                    font.family: ThemeManager.selectedTheme.typography.bodyFont
                    font.pixelSize: ThemeManager.selectedTheme.typography.baseFontSize
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 16
                spacing: 10
                opacity: imageProgress

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    visible: OverlayService.mode === OverlayService.modeImagePreview
                    color: applyMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary : "#55ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "󰄬"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 20
                        color: applyMouse.containsMouse ? ThemeManager.selectedTheme.colors.onPrimary : "white"
                    }

                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: OverlayService.requestImagePreviewApply()
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: closeMouse.containsMouse ? "#ff4444" : "#55ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "white"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeOverlay()
                    }
                }
            }
        }
        }
    }
}

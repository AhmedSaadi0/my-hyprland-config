// bars/systemtray/TrayItem.qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick.Effects

import "root:/themes"

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 13
    implicitHeight: 13

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
        anchor.window: this.QsWindow.window
    }

    // 1. الأيقونة الأصلية (المصدر) - نجعلها مخفية
    IconImage {
        id: trayIconSource
        width: parent.implicitWidth
        height: parent.implicitHeight
        source: root.modelData.icon
        anchors.centerIn: parent
        visible: false // نخفيها لأننا سنعرض النسخة الملونة
    }

    // 2. المؤثر الذي سيقوم بتلوين الأيقونة
    MultiEffect {
        id: coloredIcon
        anchors.fill: trayIconSource
        source: trayIconSource

        // تفعيل التلوين الكامل
        colorization: 1.0

        colorizationColor: ThemeManager.selectedTheme.colors.topbarFgColorV2

        // لتصحيح التباين والسطوع في حال كانت الأيقونة الأصلية باهتة
        brightness: 0.0
        contrast: 0.0
    }
}

// bars/systemtray/SystemTray.qml

import Quickshell.Services.SystemTray
import QtQuick
import "root:/themes"

Rectangle {
    id: root

    readonly property var theme: ThemeManager.selectedTheme
    readonly property Repeater items: trayRepeater

    color: theme.colors.topbarBgColorV2
    radius: theme.dimensions.elementRadius

    border.color: Qt.rgba(1, 1, 1, 0.05)
    border.width: 1

    clip: true
    visible: trayRepeater.count > 0

    implicitWidth: layout.implicitWidth + (theme.dimensions.spacingMedium * 3)
    // implicitHeight: layout.implicitHeight + (theme.dimensions.spacingSmall * 2)
    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight

    Row {
        id: layout
        // توسيط الأيقونات داخل الخلفية
        anchors.centerIn: parent
        spacing: 9

        // حركة دخول الأيقونات الجديدة
        add: Transition {
            NumberAnimation {
                properties: "scale, opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutBack
            }
        }

        Repeater {
            id: trayRepeater
            model: SystemTray.items
            delegate: TrayItem {}
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
}

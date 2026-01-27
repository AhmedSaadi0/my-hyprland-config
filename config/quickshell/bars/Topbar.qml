import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Hyprland

import "../themes"
import "./widgets"
import "./systemtray"
import "../components"

PanelWindow {
    id: topBar

    // --- 1. الإعدادات الأساسية ---
    readonly property var theme: ThemeManager.selectedTheme
    implicitHeight: theme.dimensions.barHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    anchors {
        top: true
        left: true
        right: true
    }

    signal openLeftPanelRequested(var btn)
    property bool menuIsOpen: false

    // --- 2. الحاوية الرئيسية (Main Layout) ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: theme.dimensions.spacingMedium
        anchors.rightMargin: theme.dimensions.spacingMedium
        spacing: 0

        // --- الجزء الأيسر (Left Section) ---
        RowLayout {
            id: leftSection
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            spacing: theme.dimensions.spacingMedium

            SystemTray {
                id: systemTray
                height: theme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}
            }

            NetworkSpeedIndicator {
                id: internetIndicator
                height: theme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}
            }

            ActiveWindow {
                id: activeWindow
                height: theme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}
            }
        }

        // مساحة فارغة في المنتصف تدفع العناصر للأطراف
        Item {
            Layout.fillWidth: true
        }

        // --- الجزء الأيمن (Right Section) ---
        RowLayout {
            id: rightSection
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 10

            // ويدجت الشاشات (Monitors)
            Rectangle {
                id: monitorsWrapper
                width: 260
                height: theme.dimensions.barWidgetsHeight
                radius: theme.dimensions.elementRadius
                color: theme.colors.topbarBgColorV1

                layer.enabled: true
                layer.effect: Shadow {}

                Monitors {
                    id: monitors
                    anchors.centerIn: parent
                    implicitHeight: parent.implicitHeight
                    height: parent.height
                }
            }

            // مساحات العمل (Workspaces)
            Item {
                id: workspacesContainer
                property int maxWorkspacesWidth: 400
                Layout.preferredHeight: theme.dimensions.barWidgetsHeight
                Layout.preferredWidth: Math.min(workspaces.childrenRect.width, maxWorkspacesWidth)
                clip: true

                layer.enabled: true
                layer.effect: Shadow {}

                Flickable {
                    id: workspacesFlickable
                    anchors.fill: parent

                    contentWidth: workspaces.childrenRect.width
                    contentHeight: parent.height

                    flickableDirection: Flickable.HorizontalFlick
                    interactive: true

                    boundsBehavior: Flickable.StopAtBounds

                    Workspaces {
                        id: workspaces
                        height: parent.height

                        width: childrenRect.width + 10
                    }

                    WheelHandler {
                        target: workspacesFlickable
                        orientation: Qt.Horizontal
                        onWheel: event => {
                            let scrollStep = 40; // سرعة السكرول
                            if (event.angleDelta.y > 0)
                                workspacesFlickable.contentX = Math.max(0, workspacesFlickable.contentX - scrollStep);
                            else
                                workspacesFlickable.contentX = Math.min(workspacesFlickable.contentWidth - workspacesFlickable.width, workspacesFlickable.contentX + scrollStep);
                        }
                    }

                    Behavior on contentX {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}

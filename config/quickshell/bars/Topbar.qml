// bars/Topbar.qml

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
    property int innerRadiusDiv: 4
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
            spacing: theme.dimensions.spacingSmall

            SystemTray {
                id: systemTray
                height: theme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}

                topRightRadius: theme.dimensions.elementRadius / innerRadiusDiv
                bottomRightRadius: theme.dimensions.elementRadius / innerRadiusDiv
            }

            NetworkSpeedIndicator {
                id: internetIndicator
                height: theme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}

                radius: theme.dimensions.elementRadius / innerRadiusDiv
            }

            ActiveWindow {
                id: activeWindow
                height: theme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}

                bottomLeftRadius: theme.dimensions.elementRadius / innerRadiusDiv
                topLeftRadius: theme.dimensions.elementRadius / innerRadiusDiv
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
            // spacing: 10
            spacing: theme.dimensions.spacingSmall

            Rectangle {
                id: monitorsWrapper
                property int maxWidth: 300

                Layout.preferredWidth: Math.min(monitors.implicitWidth + 10, maxWidth)
                Layout.maximumWidth: maxWidth
                Layout.preferredHeight: theme.dimensions.barWidgetsHeight

                radius: theme.dimensions.elementRadius
                color: theme.colors.topbarBgColorV1
                clip: true

                topRightRadius: theme.dimensions.elementRadius / innerRadiusDiv
                bottomRightRadius: theme.dimensions.elementRadius / innerRadiusDiv

                layer.enabled: true
                layer.effect: Shadow {}

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.6
                    }
                }

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.6
                    }
                }

                Flickable {
                    id: monitorsFlick

                    width: parent.width
                    height: parent.height

                    contentWidth: monitors.implicitWidth
                    contentHeight: parent.height

                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentWidth > width

                    contentX: contentWidth < width ? -(width - contentWidth) / 2 : 0

                    Monitors {
                        id: monitors
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

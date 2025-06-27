import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import "../themes"

PanelWindow {
    id: root
    implicitWidth: 250
    implicitHeight: 80
    color: "transparent"
    visible: false

    exclusionMode: ExclusionMode.Ignore

    margins {
        bottom: 100
    }

    anchors {
        bottom: true
    }

    property bool showing: false
    property QtObject target
    property QtObject component
    // property var sliderValue
    property real sliderValue: 0.5
    property color bgColor: ThemeManager.selectedTheme.colors.volOsdBgColor
    property string valueTextIcon: ""
    property QtObject valueTextIconFont: ThemeManager.selectedTheme.typography.iconFont
    property color valueTextColor: ThemeManager.selectedTheme.colors.volOsdFgColor
    property real animationEasing: Easing.OutBack
    signal valueChanged(real newValue)

    Timer {
        id: hideContainerTimer
        interval: 3000
        repeat: false
        onTriggered: root.showing = false
    }

    Timer {
        id: hideViewTimer
        interval: 4000
        repeat: false
        onTriggered: root.visible = false
    }

    Connections {
        target: root.target
        function onVolumeChanged() {
            root.showing = true;
            root.visible = true;
            hideContainerTimer.restart();
            hideViewTimer.restart();
        }
    }

    // عنصر للحركة
    Item {
        id: panelContainer
        anchors.fill: parent

        states: State {
            name: "visible"
            when: root.showing
            PropertyChanges {
                target: panelContent
                y: 10
                opacity: 1
            }
        }

        transitions: Transition {
            NumberAnimation {
                properties: "y, opacity"
                duration: 300
                easing.type: root.animationEasing
            }
        }

        // محتوى البانل الكامل
        Rectangle {
            id: panelContent
            implicitWidth: 200
            implicitHeight: 50
            color: root.bgColor
            radius: 15
            y: 50
            opacity: 0
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.verticalCenter: parent.verticalCenter

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 1.1
                shadowColor: "#55000000"
                shadowHorizontalOffset: 4
                shadowVerticalOffset: 4
                shadowOpacity: 0.5
            }

            RowLayout {
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 5

                LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
                LayoutMirroring.childrenInherit: true

                Slider {
                    id: volumeSlider
                    from: 0.0
                    to: 1.0
                    value: root.sliderValue
                    Layout.fillWidth: true
                    onValueChanged: root.valueChanged(value)
                }

                Text {
                    Layout.leftMargin: 10
                    text: root.valueTextIcon
                    color: root.valueTextColor
                    font.family: root.valueTextIconFont
                }
            }
        }
    }
}

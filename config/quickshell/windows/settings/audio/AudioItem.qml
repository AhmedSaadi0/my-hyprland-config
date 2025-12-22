// windows/settings/audio/AudioItem.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "root:/components"

Rectangle {
    id: root

    // Node attrs -> https://quickshell.org/docs/master/types/Quickshell.Services.Pipewire/PwNode/
    property var device
    property var selectedTheme

    property string deviceTitle: device.description || ""
    property string deviceDescription: device.name
    property bool isSink: device.isSink
    property bool isDefaultDevice: {
        if (!device)
            return false;

        if (isSink) {
            return Pipewire.defaultAudioSink && (device.id === Pipewire.defaultAudioSink.id);
        } else {
            return Pipewire.defaultAudioSource && (device.id === Pipewire.defaultAudioSource.id);
        }
    }

    width: 610
    implicitHeight: 75
    radius: selectedTheme.dimensions.elementRadius
    color: selectedTheme.colors.leftMenuBgColorV1

    Behavior on border.width {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    border.width: isDefaultDevice ? 2 : 0
    border.color: isDefaultDevice ? selectedTheme.colors.primary : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: selectedTheme.dimensions.spacingLarge + 10
        anchors.rightMargin: selectedTheme.dimensions.spacingLarge + 10
        spacing: selectedTheme.dimensions.spacingLarge

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24

            Rectangle {
                visible: root.isDefaultDevice
                width: 24
                height: 24
                anchors.centerIn: parent
                radius: selectedTheme.dimensions.elementRadius
                color: selectedTheme.colors.secondary
            }

            Rectangle {
                id: innerCircle
                width: 12
                height: 12
                anchors.centerIn: parent
                radius: selectedTheme.dimensions.elementRadius
                color: root.isDefaultDevice ? selectedTheme.colors.primary : selectedTheme.colors.primary.alpha(0.3)
                Behavior on color {
                    ColorAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "🔊"
            font.pixelSize: 24
            color: selectedTheme.colors.leftMenuFgColorV1
            font.family: selectedTheme.typography.iconFont
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: root.deviceTitle
                color: selectedTheme.colors.leftMenuFgColorV1
                font.bold: true
                font.pixelSize: 16
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                text: root.deviceDescription
                color: selectedTheme.colors.leftMenuFgColorV1
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.preferredWidth: 150
            Layout.alignment: Qt.AlignVCenter

            MButton {
                id: setDefaultButton
                anchors.centerIn: parent
                width: 140
                height: 35
                text: qsTr("Set Default")
                opacity: root.isDefaultDevice ? 0 : 1

                // visible: !root.isDefaultDevice

                onClicked: {
                    if (isSink) {
                        Pipewire.preferredDefaultAudioSink = device;
                    } else {
                        Pipewire.preferredDefaultAudioSource = device;
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            RowLayout {
                visible: root.isDefaultDevice
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "✔"
                    color: selectedTheme.colors.primary
                    font.bold: true
                }
                Text {
                    text: qsTr("Default Device")
                    color: selectedTheme.colors.leftMenuFgColorV1
                    font.pixelSize: 14
                }
            }
        }
    }
}

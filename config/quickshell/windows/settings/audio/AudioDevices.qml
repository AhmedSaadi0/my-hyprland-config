// settings/MonitorSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import Quickshell.Services.Pipewire

import "root:/windows/settings/components/base"
import "root:/windows/settings/audio"
import "root:/components"
import "root:/themes"

M3GroupBox {
    id: devicesList
    title: qsTr("Audio Devices Settings")
    icon: ""

    property var selectedTheme: ThemeManager.selectedTheme

    signal close

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink) {
                acc.sinks.push(node);
            } else if (node.audio) {
                acc.sources.push(node);
            }
        }
        return acc;
    }, {
        "sources": [],
        "sinks": []
    })

    Label {
        text: qsTr("Output Devices")
        font.pixelSize: selectedTheme.typography.heading3Size
        font.bold: true
    }

    ListView {
        id: outputDevicesView
        model: nodes.sinks
        spacing: 10

        Layout.fillWidth: true
        implicitHeight: contentHeight

        delegate: AudioItem {
            required property int index
            device: nodes.sinks[index]
            selectedTheme: devicesList.selectedTheme
        }

        // --- قسم الأنميشن ---
        add: Transition {
            // حركة عند إضافة عنصر: ظهور تدريجي مع تمدد بسيط
            NumberAnimation {
                properties: "opacity, scale"
                from: 0
                to: 1.0
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        remove: Transition {
            // حركة عند إزالة عنصر: اختفاء تدريجي مع تقلص
            NumberAnimation {
                properties: "opacity, scale"
                to: 0
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }

    // --- قسم أجهزة الإدخال ---
    Label {
        text: qsTr("Input Devices")
        font.pixelSize: selectedTheme.typography.heading3Size
        font.bold: true
        Layout.topMargin: 20
    }

    // --- التحسين الرئيسي: استخدام ListView آخر لأجهزة الإدخال ---
    ListView {
        id: inputDevicesView
        model: nodes.sources
        spacing: 10

        implicitHeight: contentHeight

        delegate: AudioItem {
            required property int index
            device: nodes.sources[index]
            selectedTheme: devicesList.selectedTheme
        }

        add: Transition {
            NumberAnimation {
                properties: "opacity, scale"
                from: 0
                to: 1.0
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        remove: Transition {
            NumberAnimation {
                properties: "opacity, scale"
                to: 0
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }

    footer: RowLayout {
        spacing: selectedTheme.dimensions.spacingMedium
        Item {
            Layout.fillWidth: true
        }

        MButton {
            text: "Close"
            Layout.preferredWidth: 80
            highlighted: true
            onClicked: close()
        }
    }
}

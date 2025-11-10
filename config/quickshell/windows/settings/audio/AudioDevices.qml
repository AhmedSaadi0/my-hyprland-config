// settings/MonitorSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import Quickshell.Services.Pipewire
// لا حاجة لـ import QtQuick.Controls مرة أخرى

// استيراد مكونات المشروع
import "root:/components"
import "root:/windows/settings/audio"

M3GroupBox {
    id: devicesList
    title: qsTr("Audio Devices")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    // هذا الجزء ممتاز ولا يحتاج لتغيير
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

    // --- قسم أجهزة الإخراج ---
    Label {
        text: qsTr("Output Devices")
        font.pixelSize: selectedTheme.typography.heading3Size
        font.bold: true
    }

    // --- التحسين الرئيسي: استخدام ListView بدلاً من Repeater ---
    ListView {
        id: outputDevicesView
        model: nodes.sinks
        spacing: 10 // إضافة مسافة بين العناصر

        // إدارة التخطيط: اجعل ListView يملأ العرض المتاح
        // ويكون ارتفاعه على قدر المحتوى
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
        spacing: 10 // إضافة مسافة بين العناصر

        // إدارة التخطيط
        Layout.fillWidth: true
        implicitHeight: contentHeight

        delegate: AudioItem {
            required property int index
            device: nodes.sources[index]
            selectedTheme: devicesList.selectedTheme
        }

        // --- قسم الأنميشن (نفس الحركات ليكون التصميم متناسقًا) ---
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
    }
}

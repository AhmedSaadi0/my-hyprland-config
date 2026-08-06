// windows/settings/monitors/LayoutPreview.qml
// خريطة مصغّرة نسبية لترتيب الشاشات (يمين/يسار/فوق/تحت) حسب إحداثيات Hyprland

import QtQuick
import QtQuick.Layouts

import "root:/themes"

Rectangle {
    id: root

    property var monitors: []
    property var selectedTheme: ThemeManager.selectedTheme

    // الشاشات التي لها موضع مستقل (غير معطلة وغير مرآة)
    readonly property var usable: Array.isArray(monitors) ? monitors.filter(m => !m.disabled && typeof m.mirrorOf !== "number") : []

    readonly property int minX: usable.length ? Math.min(...usable.map(m => m.x)) : 0
    readonly property int minY: usable.length ? Math.min(...usable.map(m => m.y)) : 0
    readonly property int maxX: usable.length ? Math.max(...usable.map(m => m.x + m.width)) : 1
    readonly property int maxY: usable.length ? Math.max(...usable.map(m => m.y + m.height)) : 1

    // عامل تصغير يناسب المساحة المتاحة مع حد أقصى 4x
    readonly property real scaleFactor: {
        if (!usable.length)
            return 1;
        const availW = Math.max(1, width - 24);
        const availH = Math.max(1, height - 24);
        return Math.min(availW / (maxX - minX), availH / (maxY - minY), 4);
    }

    Layout.fillWidth: true
    color: selectedTheme.colors.surfaceContainer.alpha(0.6)
    radius: selectedTheme.dimensions.elementRadius
    border.color: selectedTheme.colors.primary.alpha(0.12)
    border.width: 1
    implicitHeight: 150

    Text {
        anchors.centerIn: parent
        visible: root.usable.length === 0
        text: qsTr("No active displays detected")
        color: selectedTheme.colors.onSurfaceVariant
        font.pixelSize: 12
    }

    Item {
        id: canvas
        anchors.fill: parent
        anchors.margins: 12
        clip: true

        Repeater {
            model: root.usable

            delegate: Rectangle {
                required property var modelData

                readonly property int pw: Math.max(10, Math.round(modelData.width * root.scaleFactor))
                readonly property int ph: Math.max(10, Math.round(modelData.height * root.scaleFactor))

                x: Math.round((modelData.x - root.minX) * root.scaleFactor)
                y: Math.round((modelData.y - root.minY) * root.scaleFactor)
                width: pw
                height: ph

                radius: 6
                clip: true
                color: modelData.focused ? selectedTheme.colors.primary.alpha(0.35) : selectedTheme.colors.surfaceContainerHigh
                border.width: modelData.focused ? 2 : 1
                border.color: modelData.focused ? selectedTheme.colors.primary : selectedTheme.colors.secondary.alpha(0.5)

                Text {
                    anchors.centerIn: parent
                    text: modelData.name + "\n" + modelData.width + "x" + modelData.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: modelData.focused ? selectedTheme.colors.onPrimary : selectedTheme.colors.onSurface
                    font.pixelSize: 9
                    font.bold: modelData.focused
                }
            }
        }
    }
}

// windows/leftwindow/monitoring/components/DiskRow.qml
import QtQuick
import QtQuick.Layouts

import "root:/themes"

// =============================================================================
//  صف قرص واحد: الماونت ← بروقرس عرضي (كم مستخدم) ← النسبة %
//  مكوّن خاص بكرت الأقراص — لا يستخدم أي مكوّن جدول
// =============================================================================
RowLayout {
    id: root

    // =========================================================================
    //  Public Properties
    // =========================================================================
    property string mount: "/"
    property real percent: 0

    Layout.fillWidth: true
    Layout.preferredHeight: 30

    // لون التعبئة حسب الامتلاء: primary < 85% · secondary 85-93% · error > 93%
    readonly property color fillColor: {
        var colors = ThemeManager.selectedTheme.colors;
        if (root.percent >= 93) return colors.error;
        if (root.percent >= 85) return colors.secondary;
        return colors.primary;
    }

    // =========================================================================
    //  Content
    // =========================================================================

    // --- الماونت ---
    Text {
        Layout.preferredWidth: 100
        Layout.maximumWidth: 110

        text: root.mount
        font.pixelSize: ThemeManager.selectedTheme.typography.small
        color: ThemeManager.selectedTheme.colors.onSurface
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
    }

    // --- المسار (Track) ---
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 8

        radius: ThemeManager.selectedTheme.dimensions.shapeExtraSmall
        color: ThemeManager.selectedTheme.colors.surfaceContainer

        // --- التعبئة (Fill) ---
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width * Math.min(root.percent / 100, 1)
            radius: parent.radius
            color: root.fillColor
        }
    }

    // --- النسبة المئوية ---
    Text {
        Layout.preferredWidth: 44

        text: Math.round(root.percent) + "%"
        font.pixelSize: ThemeManager.selectedTheme.typography.small
        color: ThemeManager.selectedTheme.colors.onSurfaceVariant
        horizontalAlignment: Text.AlignRight
    }
}

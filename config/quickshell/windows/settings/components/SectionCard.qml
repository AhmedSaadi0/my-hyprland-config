pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import "root:/components"
import "root:/config"
import "root:/themes"

Rectangle {
    id: card
    
    property string title: ""
    property string subtitle: ""
    
    // يحاول الوصول للثيم من الأب أو يستخدم الـ Singleton الافتراضي
    property var theme: (parent && parent.theme !== undefined) ? parent.theme : ThemeManager.selectedTheme
    
    // دالة مساعدة للخطوط تعتمد على الثيم المتوفر
    function typ(k, d) {
        return theme ? (theme.typography[k] || d) : d
    }
    
    default property alias content: sectionContent.data

    Layout.fillWidth: true
    color: theme.colors.surfaceContainer.alpha(0.72)
    radius: theme.dimensions.baseRadius
    border.color: theme.colors.primary.alpha(0.12)
    border.width: 1

    implicitHeight: sectionColumn.implicitHeight + 28

    ColumnLayout {
        id: sectionColumn
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Controls.Label {
                text: card.title
                font.pixelSize: card.typ("heading4Size", 16)
                font.bold: true
                color: card.theme.colors.primary
            }

            SettingsHelperText {
                visible: card.subtitle !== ""
                text: card.subtitle
                Layout.preferredWidth: 540
            }
        }

        ColumnLayout {
            id: sectionContent
            Layout.fillWidth: true
            spacing: 12
        }
    }
}

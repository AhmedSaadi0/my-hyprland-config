// Card.qml
import QtQuick
import QtQuick.Controls // Pane is in Controls
import QtQuick.Layouts

import "root:/themes"

Pane {
    id: root

    width: parent.width

    height: contentItem.implicitHeight + padding * 2
    implicitHeight: contentItem.implicitHeight + padding * 2

    property alias title: titleElement.text
    property alias icon: iconElement.text
    default property alias content: contentColumn.data

    property color cardColor: ThemeManager.selectedTheme.colors.topbarBgColorV1
    property color textColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
    property int cardRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int headerSpacing: 10
    property int contentSpacing: 10 // مسافة بين عناصر المحتوى المضافة

    property int titleFontSize: ThemeManager.selectedTheme.typography.heading3Size
    property int iconFontSize: ThemeManager.selectedTheme.typography.heading3Size
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont

    background: Rectangle {
        color: root.cardColor
        radius: root.cardRadius
    }

    contentItem: ColumnLayout {
        RowLayout {
            id: headerRow
            visible: root.title.length > 0
            spacing: root.headerSpacing

            Layout.fillWidth: true

            Text {
                id: iconElement
                text: "\uf128"
                font.family: root.iconFontFamily
                font.pixelSize: root.iconFontSize
                color: root.textColor
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                id: titleElement
                text: ""
                font.pixelSize: root.titleFontSize
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Rectangle {
            id: separator
            visible: headerRow.visible && contentColumn.children.length > 0
            Layout.fillWidth: true
            Layout.topMargin: root.padding / 2
            Layout.bottomMargin: root.padding / 2
            height: 1
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.2)
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: root.contentSpacing
        }
    }
}

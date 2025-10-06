// components/MenuCard.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls // Pane is in Controls
import QtQuick.Layouts

import "root:/themes"

Pane {
    id: root

    width: parent.width

    height: contentItem.implicitHeight + padding * 2
    implicitHeight: height

    property alias title: titleElement.text
    property alias subtitle: subtitleElement.text
    property alias icon: iconElement.text
    property alias iconItem: iconElement

    default property alias content: contentColumn.data

    property color cardColor: ThemeManager.selectedTheme.colors.topbarBgColorV1
    property color textColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
    property int cardRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int headerSpacing: 10
    property int contentSpacing: 10 // مسافة بين عناصر المحتوى المضافة

    property int cardLeftPadding: 5
    property int cardRightPadding: 5

    property int titleFontSize: ThemeManager.selectedTheme.typography.heading3Size
    property int subtitleFontSize: ThemeManager.selectedTheme.typography.small
    property int iconFontSize: ThemeManager.selectedTheme.typography.heading3Size
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont

    property var heightEasingType: Easing.InOutQuad
    property var heightAnimationDuration: 300
    property var iconCursorShape: Qt.ArrowCursor

    signal iconClicked(var mouse)

    Behavior on height {
        NumberAnimation {
            duration: root.heightAnimationDuration
            easing.type: root.heightEasingType
        }
    }

    background: Rectangle {
        color: root.cardColor
        radius: root.cardRadius
    }

    contentItem: ColumnLayout {

        RowLayout {
            id: headerRow
            visible: root.title.length > 0
            spacing: root.headerSpacing

            Layout.leftMargin: root.cardLeftPadding
            Layout.rightMargin: root.cardRightPadding

            Layout.fillWidth: true

            Column {
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

                Text {
                    id: subtitleElement
                    text: ""
                    font.pixelSize: root.subtitleFontSize
                    font.bold: true
                    color: root.textColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Item {
                Layout.fillWidth: true
            } // Separator

            Text {
                id: iconElement
                text: "\uf128"
                font.family: root.iconFontFamily
                font.pixelSize: root.iconFontSize
                color: root.textColor
                layer.enabled: true
                layer.smooth: true
                antialiasing: true
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: iconElement
                    cursorShape: root.iconCursorShape
                    onClicked: function (mouse) {
                        root.iconClicked(mouse);
                    }
                }
            }
        }

        Rectangle {
            id: separator
            visible: headerRow.visible && contentColumn.children.length > 0
            Layout.fillWidth: true
            Layout.topMargin: root.padding / 2
            Layout.bottomMargin: root.padding / 2

            Layout.leftMargin: root.cardLeftPadding
            Layout.rightMargin: root.cardRightPadding
            Layout.preferredHeight: 1

            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.2)
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            Layout.leftMargin: root.cardLeftPadding
            Layout.rightMargin: root.cardRightPadding
            spacing: root.contentSpacing
        }
    }
}

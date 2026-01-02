// windows/leftwindow/clipboard/ClipboardHeader.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 50
    color: "transparent"

    signal clearAllClicked
    property alias searchText: searchField.text

    property bool isSearching: false

    function focusSearch() {
        root.isSearching = true;
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // 1. العنوان (يظهر فقط عندما لا نبحث)
        Label {
            visible: !root.isSearching
            text: qsTr("Clipboard History")
            font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
            font.bold: true
            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            Layout.fillWidth: true
        }

        // 2. حقل البحث (يظهر فقط عند البحث)
        TextField {
            id: searchField
            visible: root.isSearching
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            placeholderText: qsTr("Search...")
            font.family: ThemeManager.selectedTheme.typography.bodyFont
            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1

            // تخصيص شكل حقل البحث ليناسب الثيم
            background: Rectangle {
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.05)
                radius: 4
                border.width: 1
                border.color: searchField.activeFocus ? ThemeManager.selectedTheme.colors.primary : "transparent"
            }

            onVisibleChanged: {
                if (!visible)
                    text = "";
                else
                    forceActiveFocus();
            }

            Keys.onEscapePressed: {
                root.isSearching = false;
                text = "";
                focus = false;
            }
        }

        // 3. زر تفعيل/إلغاء البحث
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: searchMA.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.15) : "transparent"

            Text {
                anchors.centerIn: parent
                text: root.isSearching ? "󰅖" : "󰍉"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                color: searchMA.containsMouse ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.subtleText
            }

            MouseArea {
                id: searchMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.isSearching = !root.isSearching;
                }
            }
        }

        // 4. زر الحذف (Clear All)
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: clearMA.containsMouse ? ThemeManager.selectedTheme.colors.error.alpha(0.15) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰆴"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                color: clearMA.containsMouse ? ThemeManager.selectedTheme.colors.error : ThemeManager.selectedTheme.colors.subtleText
            }

            MouseArea {
                id: clearMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clearAllClicked()
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.1)
    }
}

// windows/leftwindow/applauncher/AppsHeader.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/components"

HeaderCard {
    id: headerRoot

    // --- Signals ---
    // (تم حذف searchTextChanged لتجنب التعارض لأن property alias تنشئها تلقائياً)
    signal moveSelection(int direction)
    signal activateSelection
    signal escapePressed

    // --- Properties ---
    property alias searchText: searchField.text

    // Theme Helpers
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions

    Layout.fillWidth: true
    Layout.preferredHeight: 80
    Layout.leftMargin: 10
    Layout.rightMargin: 10
    Layout.bottomMargin: 10

    function forceSearchFocus() {
        searchField.forceActiveFocus();
    }

    function appendText(text) {
        searchField.text += text;
    }

    EditableField {
        id: searchField
        Layout.fillHeight: true
        Layout.fillWidth: true
        // anchors.fill: parent
        Layout.margins: 10
        Layout.topMargin: 0

        placeholderText: qsTr("Search apps... or use > for commands")
        font.pixelSize: 16

        normalBackground: colors.leftMenuBgColorV1
        normalForeground: colors.leftMenuFgColorV1
        focusedBorderColor: colors.primary
        borderColor: colors.primary
        borderSize: 1

        topLeftRadius: dims.elementRadius
        topRightRadius: dims.elementRadius
        bottomLeftRadius: dims.elementRadius
        bottomRightRadius: dims.elementRadius

        onAccepted: {
            headerRoot.activateSelection();
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Down) {
                headerRoot.moveSelection(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                headerRoot.moveSelection(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                headerRoot.activateSelection();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                headerRoot.escapePressed();
                event.accepted = true;
            }
        }
    }
}

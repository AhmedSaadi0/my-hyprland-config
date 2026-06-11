// windows/leftwindow/applauncher/AppsHeader.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/components"
import "root:/windows/leftwindow/base"

HeaderCard {
    id: headerRoot
    color: "transparent"

    signal moveSelection(int direction)
    signal activateSelection
    signal escapePressed

    property alias searchText: searchField.text
    property alias selectedCategory: categoryFilter.selectedCategory
    readonly property bool isCommandMode: searchField.text.length > 0 && searchField.text.charAt(0) === ">"

    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions

    function forceSearchFocus() {
        searchField.forceActiveFocus();
    }

    function appendText(text) {
        searchField.text += text;
    }

    EditableField {
        id: searchField
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        placeholderText: qsTr("Search apps... or use > for commands")
        font.pixelSize: 16

        normalBackground: colors.surfaceContainer
        normalForeground: colors.onSurface
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

    CategoryFilter {
        id: categoryFilter
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        visible: !headerRoot.isCommandMode
        opacity: visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }
}

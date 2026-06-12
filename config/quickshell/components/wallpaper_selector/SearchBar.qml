// components/wallpaper_selector/SearchBar.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "root:/themes"
import "root:/components"

RowLayout {
    id: root

    property int sourceMode: 0
    property alias text: searchField.text
    readonly property var theme: ThemeManager.selectedTheme

    signal searchRequested
    signal filterTextChanged(string text)

    spacing: 8

    EditableField {
        id: searchField
        Layout.fillWidth: true
        Layout.preferredHeight: 36

        placeholderText: root.sourceMode === 2 
            ? qsTr("Search Wallhaven (e.g. nature, anime, abstract)...")
            : qsTr("Filter wallpapers...")
        font.pixelSize: 13
        horizontalAlignment: Text.AlignLeft

        normalBackground: root.theme.colors.surfaceContainerHigh
        normalForeground: root.theme.colors.onSurface
        focusedBorderColor: root.theme.colors.primary
        borderColor: root.theme.colors.primary.alpha(0.3)
        borderSize: 1

        topLeftRadius: root.theme.dimensions.elementRadius
        topRightRadius: root.theme.dimensions.elementRadius
        bottomLeftRadius: root.theme.dimensions.elementRadius
        bottomRightRadius: root.theme.dimensions.elementRadius

        onTextChanged: root.filterTextChanged(text)
        onAccepted: {
            if (root.sourceMode === 2) {
                root.searchRequested();
            }
        }
    }

    // Search button for Wallhaven
    Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: root.theme.dimensions.elementRadius
        visible: root.sourceMode === 2
        color: searchBtnMouse.containsMouse ? root.theme.colors.primary : root.theme.colors.primary.alpha(0.8)

        Text {
            anchors.centerIn: parent
            text: "󰍉"
            font.pixelSize: 16
            font.family: root.theme.typography.iconFont
            color: root.theme.colors.onPrimary
        }

        MouseArea {
            id: searchBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.searchRequested()
        }
    }
}

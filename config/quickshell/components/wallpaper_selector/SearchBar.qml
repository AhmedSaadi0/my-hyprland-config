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

        normalBackground: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
        normalForeground: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
        focusedBorderColor: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
        borderColor: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#444"
        borderSize: 1

        topLeftRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
        topRightRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
        bottomLeftRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
        bottomRightRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8

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
        radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
        visible: root.sourceMode === 2
        color: searchBtnMouse.containsMouse
            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
            : ThemeManager.selectedTheme?.colors?.primary.alpha(0.8) || "#5558e8"

        Text {
            anchors.centerIn: parent
            text: "󰍉"
            font.pixelSize: 16
            font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
            color: "#fff"
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

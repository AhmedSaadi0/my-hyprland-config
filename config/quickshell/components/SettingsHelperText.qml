// components/SettingsHelperText.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import "root:/themes"

Controls.Label {
    id: root

    // property alias text: root.text

    // text: qsTr("Automatically cycle through a collection of wallpapers from a selected folder.")
    font.pixelSize: ThemeManager.selectedTheme.typography.small
    color: ThemeManager.selectedTheme.colors.subtleText
    wrapMode: Text.WordWrap
    Layout.preferredWidth: 500
}

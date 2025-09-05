import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs

import "root:/components"
import "root:/themes"

M3GroupBox {
    id: root
    title: qsTr("General")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme
    Controls.Label {
        Layout.fillWidth: true
        Layout.fillHeight: true
        font.pixelSize: selectedTheme.typography.heading1Size
        // titleFontWeight: Font.ExtraBold
        text: "Soon"
    }
}

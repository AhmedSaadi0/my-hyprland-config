import QtQuick
import QtQuick.Controls

import "../../../themes"

Item {
    id: view1
    objectName: "view3" // objectName for debugging
    // Layout.fillWidth: true; Layout.fillHeight: true // Implicit with StackLayout
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    }
    Label {
        anchors.centerIn: parent
        text: "Content of View 3"
        color: "#000"
    }
}

import QtQuick
import QtQuick.Controls

import "../../../themes"

Item {
    id: view1
    objectName: "view1" // objectName for debugging
    // Layout.fillWidth: true; Layout.fillHeight: true // Implicit with StackLayout
    Rectangle {
        anchors.fill: parent
        color: "lightblue"
        radius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    }
    Label {
        anchors.centerIn: parent
        text: "Content of View 1"
        color: "#000"
    }
}

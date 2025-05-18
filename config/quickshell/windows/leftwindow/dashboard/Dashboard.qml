import QtQuick
import QtQuick.Controls

import "../../../themes"

Item {
    id: view1
    objectName: "view1" // objectName for debugging
    // Layout.fillWidth: true; Layout.fillHeight: true // Implicit with StackLayout
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        // color: "lightblue"
        radius: ThemeManager.selectedTheme.dimensions.elementRadius - 5

        PowerProfiles {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    Label {
        anchors.centerIn: parent
        text: "Content of View 1"
        color: "#000"
    }
}

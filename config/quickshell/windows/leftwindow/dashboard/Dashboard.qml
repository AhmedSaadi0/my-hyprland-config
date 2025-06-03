// windows/leftwindow/dashboard/Dashboard.qml
import QtQuick
// import QtQuick.Controls

import "../../../themes"

Item {
    id: dashboardMenu
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
}

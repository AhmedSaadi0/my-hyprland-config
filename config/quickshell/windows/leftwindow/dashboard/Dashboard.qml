// windows/leftwindow/dashboard/Dashboard.qml

// import QtQuick.Controls
import QtQuick

import "root:/themes"

Column {
    // color: "transparent"
    // width: ThemeManager.selectedTheme.dimensions.menuWidth
    // height: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight

    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    PowerProfiles {
        id: powerProfiles
        // anchors {
        //     top: parent.top
        //     // horizontalCenter: parent.horizontalCenter
        //     leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        //     rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        // }
    }

    PowerOptions {
        id: powerOptions
        // width: parent.width
        // anchors {
        //     // horizontalCenter: parent.horizontalCenter
        //     top: powerProfiles.bottom
        //     topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        //     leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        //     rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        // }
    }
}

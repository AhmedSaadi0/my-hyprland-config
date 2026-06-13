// windows/leftwindow/dashboard/Dashboard.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/themes"
import "root:/components"
import ".."

ColumnLayout {
    id: dashboardScroller

    // width: parent.width
    height: parent.height
    width: dashboardScroller.availableWidth
    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    Header {
        id: dashboardHeader
        Layout.fillWidth: true
        // Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
    }

    Themes {
        id: themes
        Layout.fillWidth: true
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
    }

    QuickActions {
        id: quickActions
        Layout.fillWidth: true
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
    }

    PowerProfiles {
        id: powerProfiles
        Layout.fillWidth: true
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
    }

    Item {
        Layout.fillHeight: true
    }
}

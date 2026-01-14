// windows/leftwindow/dashboard/Dashboard.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/themes"
import "root:/components"

ColumnLayout {
    id: dashboardScroller

    // width: parent.width
    height: parent.height
    width: dashboardScroller.availableWidth
    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    Themes {
        id: themes
        Layout.fillWidth: true
    }

    PowerProfiles {
        id: powerProfiles
        Layout.fillWidth: true
    }

    Item {
        Layout.fillHeight: true
    }
}
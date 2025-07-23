// windows/leftwindow/dashboard/Dashboard.qml (النسخة النهائية الصحيحة)

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/themes"
import "root:/components"

ScrollView {
    id: dashboardScroller
    anchors.fill: parent
    clip: true
    contentWidth: availableWidth

    ScrollBar.vertical: StyledScrollBar {
        interactive: false
    }

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ColumnLayout {
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

        PowerOptions {
            id: powerOptions
            Layout.fillWidth: true
            // Layout.topMargin: 10 // يمكن إضافة مسافة علوية لبعض الفصل
            Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin - 10
        }
    }
}

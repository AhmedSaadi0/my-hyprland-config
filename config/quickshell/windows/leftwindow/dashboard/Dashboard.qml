// windows/leftwindow/dashboard/Dashboard.qml (النسخة النهائية الصحيحة)

import QtQuick
import QtQuick.Controls // نحتاج ScrollView
import QtQuick.Layouts
import "root:/themes"
import "root:/components"

// اجعل المكون الجذري للداشبورد هو ScrollView
ScrollView {
    id: dashboardScroller
    anchors.fill: parent
    clip: true

    ScrollBar.vertical: StyledScrollBar {
        interactive: false
    }

    //
    // // 2. تخصيص مظهر شريط التمرير
    // ScrollBar.vertical.contentItem: Rectangle {
    //     // اجعل لونه شبه شفاف. يمكنك استخدام لون من الثيم
    //     color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.4)
    //
    //     // اجعل حوافه مستديرة
    //     radius: 1
    // }

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

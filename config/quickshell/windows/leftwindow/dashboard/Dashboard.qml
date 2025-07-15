// windows/leftwindow/dashboard/Dashboard.qml

import QtQuick
import "root:/themes"

// استبدل Column بـ Item ليكون الحاوية الرئيسية
Item {
    id: container

    Column {
        id: topContent

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        // anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        // العناصر العلوية تبقى هنا
        Themes {
            id: themes
            // اجعل العرض يملأ العمود
            width: parent.width
        }

        PowerProfiles {
            id: powerProfiles
            // اجعل العرض يملأ العمود
            width: parent.width
        }
    }

    // عنصر خيارات الطاقة، الآن خارج العمود العلوي
    PowerOptions {
        id: powerOptions

        // تثبيت هذا العنصر في أسفل الحاوية الرئيسية
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        anchors.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin - 10
    }
}

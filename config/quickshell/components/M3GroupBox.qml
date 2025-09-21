// components/M3GroupBox.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "root:/themes"

GroupBox {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true

    default property alias content: userContentColumn.data
    property int cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property color backgroundColor: ThemeManager.selectedTheme.colors.leftMenuBgColorV2
    // property int cornerRadius: 8
    property Component footer: undefined

    property alias titlePixelSize: titleLabel.font.pixelSize
    property alias titleFontWeight: titleLabel.font.weight
    property alias titleColor: titleLabel.color
    property alias titleTopMargin: titleLabel.topPadding
    property alias titleBottomMargin: titleLabel.bottomPadding
    property int contentAlignment: Qt.AlignCenter

    padding: 0
    topPadding: titleLabel.implicitHeight + titleLabel.topPadding + titleLabel.bottomPadding
    leftPadding: 16
    rightPadding: 16
    bottomPadding: 16

    font.pixelSize: 14
    font.weight: Font.Medium

    label: Text {
        id: titleLabel
        text: root.title
        font.pixelSize: 14
        font.weight: Font.Medium
        color: Kirigami.Theme.textColor

        topPadding: 0
        leftPadding: root.leftPadding
        rightPadding: root.rightPadding
    }

    background: Rectangle {
        radius: root.cornerRadius
        color: root.backgroundColor
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        border.width: 1
    }

    contentItem: ColumnLayout {
        width: root.availableWidth
        spacing: 0 // نتحكم في المسافات يدويًا

        // Item {
        ScrollView {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                id: userContentColumn
                spacing: 12

                anchors.horizontalCenter: (root.contentAlignment & Qt.AlignHCenter) ? parent.horizontalCenter : undefined
                anchors.left: (root.contentAlignment & Qt.AlignLeft) ? parent.left : undefined
                anchors.right: (root.contentAlignment & Qt.AlignRight) ? parent.right : undefined

                anchors.verticalCenter: (root.contentAlignment & Qt.AlignVCenter) ? parent.verticalCenter : undefined
                anchors.top: (root.contentAlignment & Qt.AlignTop) ? parent.top : undefined
                anchors.bottom: (root.contentAlignment & Qt.AlignBottom) ? parent.bottom : undefined
            }
        }

        Loader {
            id: footerLoader
            Layout.fillWidth: true
            visible: root.footer !== undefined
            sourceComponent: root.footer

            Layout.topMargin: visible ? Kirigami.Units.largeSpacing : 0
        }
    }

    // نتحكم في محتوى الـ GroupBox بالكامل
    // contentItem: Item {
    //     // نربط الأبعاد الضمنية بالـ ColumnLayout الداخلي
    //     implicitWidth: mainLayout.implicitWidth
    //     implicitHeight: mainLayout.implicitHeight
    //
    //     ColumnLayout {
    //         id: mainLayout
    //         // اجعل هذا التخطيط يملأ الـ contentItem
    //         anchors.fill: parent
    //
    //         // 1. العنوان (موجود بالفعل، لكننا نضع تحته فاصل)
    //         // لا نحتاج لإعادة تعريف العنوان هنا، GroupBox يقوم بذلك
    //
    //         // 2. الفاصل المرئي (لتمييز العنوان)
    //         Rectangle {
    //             // اجعله يظهر فقط إذا كان هناك عنوان
    //             visible: root.title.length > 0
    //
    //             Layout.fillWidth: true
    //             Layout.topMargin: 15
    //             Layout.preferredHeight: 1
    //             // Layout.bottomMargin: 10
    //             // Layout.leftMargin: -root.leftPadding // اجعل الخط يمتد ليلمس الحواف
    //             // Layout.rightMargin: -root.rightPadding
    //             // height: 1
    //             color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
    //         }
    //
    //         // 3. العمود الذي سيحتوي على محتوى المستخدم
    //         ColumnLayout {
    //             id: userContentColumn
    //             Layout.fillWidth: true
    //             spacing: 12
    //         }
    //     }
    // }
}

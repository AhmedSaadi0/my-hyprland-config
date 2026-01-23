// components/M3GroupBox.qml (OneUIHeader)

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"

Item {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true

    // --- خصائص المحتوى ---
    default property alias content: userContentColumn.data
    property Component footer: undefined

    property bool alwaysCollapsed: false

    property string title: "العنوان"
    property string icon: "\uf013"
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont

    property int expandedHeight: 200
    property int collapsedHeight: 60

    property int cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property color backgroundColor: ThemeManager.selectedTheme.colors.leftMenuBgColorV2
    property color textColor: ThemeManager.selectedTheme.colors.leftMenuFgColorV2
    property color dividerColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.1)

    // --- منطق الطي ---
    property real collapseProgress: {
        // إذا كان الطي الدائم مفعلاً، نعيد 1.0 فوراً (حالة مطوية بالكامل)
        if (root.alwaysCollapsed)
            return 1.0;

        if (!flick.visible)
            return 0;
        let range = expandedHeight - collapsedHeight;
        let p = flick.contentY / range;
        return Math.min(1.0, Math.max(0.0, p));
    }

    // الخلفية العامة
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.backgroundColor
        border.color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
        border.width: 1
        clip: true
    }

    // =========================================================
    // 1. الرأس المتحرك (Header)
    // =========================================================
    Rectangle {
        id: headerItem
        z: 10
        width: parent.width

        // تعديل الارتفاع: إذا كان الطي دائماً، نثبت الارتفاع على collapsedHeight
        height: root.alwaysCollapsed ? root.collapsedHeight : Math.max(root.collapsedHeight, root.expandedHeight - flick.contentY)

        color: root.backgroundColor
        radius: root.cornerRadius
        clip: true

        // إخفاء الزوايا السفلية لتبدو متصلة
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: root.cornerRadius
            color: root.backgroundColor
            z: -1
        }

        // خط فاصل للرأس
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: root.dividerColor
            opacity: root.collapseProgress
        }

        // المحتوى الكبير (يختفي فوراً إذا كانت alwaysCollapsed مفعلة لأن progress = 1)
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10
            opacity: 1.0 - (root.collapseProgress * 2.0)
            visible: opacity > 0
            scale: 1.0 - (root.collapseProgress * 0.4)

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 70
                height: 70
                radius: 35
                color: ThemeManager.selectedTheme.colors.primary

                Text {
                    anchors.centerIn: parent
                    text: root.icon
                    font.family: root.iconFontFamily
                    font.pixelSize: 32
                    color: ThemeManager.selectedTheme.colors.onPrimary
                    Layout.alignment: Qt.AlignCenter
                }
            }

            Text {
                text: root.title
                color: root.textColor
                font.pixelSize: ThemeManager.selectedTheme.typography.heading3Size
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // المحتوى الصغير (يظهر دائماً إذا كانت alwaysCollapsed مفعلة)
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 12
            opacity: (root.collapseProgress - 0.6) * 2.5
            visible: root.collapseProgress > 0.6

            Text {
                text: root.icon
                font.family: root.iconFontFamily
                font.pixelSize: 20
                color: root.textColor
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }

            Text {
                text: root.title
                Layout.fillWidth: true
                font.pixelSize: ThemeManager.selectedTheme.typography.heading3Size
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // =========================================================
    // 2. منطقة المحتوى (ScrollView)
    // =========================================================
    ScrollView {
        id: scrollView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerContainer.top

        clip: true

        Flickable {
            id: flick
            contentWidth: width
            contentHeight: contentLayout.implicitHeight

            ColumnLayout {
                id: contentLayout
                width: parent.width
                spacing: 0

                // A. Spacer
                // تعديل الفراغ: إذا كان الطي دائماً، نحجز مسافة صغيرة فقط (collapsedHeight)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.alwaysCollapsed ? root.collapsedHeight : root.expandedHeight
                }

                // B. محتوى المستخدم
                ColumnLayout {
                    id: userContentColumn
                    Layout.fillWidth: true
                    Layout.margins: 16
                    spacing: 12
                }

                // هامش بسيط في نهاية المحتوى
                Item {
                    Layout.preferredHeight: 10
                }
            }
        }
    }

    // =========================================================
    // 3. الفوتر الثابت (Sticky Footer)
    // =========================================================
    Rectangle {
        id: footerContainer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        radius: root.cornerRadius

        height: footerLoader.active ? footerLoader.implicitHeight + 32 : 0

        color: root.backgroundColor
        visible: height > 0
        z: 20

        // خط فاصل فوق الفوتر
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: root.dividerColor
        }

        Loader {
            id: footerLoader
            anchors.fill: parent
            anchors.margins: 16
            sourceComponent: root.footer
            active: root.footer !== undefined
        }
    }
}

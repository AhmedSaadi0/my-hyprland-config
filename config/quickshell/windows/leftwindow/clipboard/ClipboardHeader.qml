// windows/leftwindow/clipboard/ClipboardHeader.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/components"
import "root:/windows/leftwindow/base"

HeaderCard {
    id: headerRoot

    // --- Properties ---
    property alias searchText: searchField.text
    property bool isSearching: false

    // Theme Helpers
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    // --- Layout Settings ---
    Layout.fillWidth: true
    Layout.preferredHeight: 74
    Layout.leftMargin: 10
    Layout.rightMargin: 10
    Layout.bottomMargin: 10

    // --- Signals ---
    signal clearAllClicked
    signal moveSelection(int direction)
    signal activateSelection

    function focusSearch() {
        headerRoot.isSearching = true;
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    function forceSearchFocus() {
        if (headerRoot.isSearching)
            searchField.forceActiveFocus();
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 10
        spacing: 10

        // 1. العنوان (يظهر فقط عندما لا نبحث)
        Text {
            visible: !headerRoot.isSearching
            text: qsTr("Clipboard History")
            font.family: typo.bodyFont
            font.pixelSize: 18
            font.bold: true
            color: colors.onSurface
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        // 2. حقل البحث باستخدام EditableField المخصص
        EditableField {
            id: searchField
            visible: headerRoot.isSearching
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter

            // محاذاة النص لليسار (لأن EditableField افتراضياً في المنتصف)
            horizontalAlignment: Text.AlignLeft

            placeholderText: qsTr("Search...")
            font.family: typo.bodyFont

            // تخصيص الألوان بناءً على خصائص EditableField الخاصة بك
            normalBackground: colors.onSurface.alpha(0.05)
            normalForeground: colors.onSurface
            borderColor: "transparent"
            focusedBorderColor: colors.primary
            borderSize: 1

            topLeftRadius: dims.elementRadius
            topRightRadius: dims.elementRadius
            bottomLeftRadius: dims.elementRadius
            bottomRightRadius: dims.elementRadius

            onVisibleChanged: {
                if (!visible)
                    text = "";
                else
                    forceActiveFocus();
            }

            Keys.onEscapePressed: {
                headerRoot.isSearching = false;
                text = "";
                focus = false;
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) {
                    headerRoot.moveSelection(1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    headerRoot.moveSelection(-1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    headerRoot.activateSelection();
                    event.accepted = true;
                }
            }
        }

        // 3. زر تفعيل/إلغاء البحث باستخدام MButton المخصص
        MButton {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter

            showIcon: true
            iconText: headerRoot.isSearching ? "󰅖" : "󰍉"
            text: "" // إخفاء النص العادي
            textPreferredWidth: 0
            iconPreferredWidth: 16

            // الألوان
            normalBackground: "transparent"
            normalForeground: colors.onSurfaceVariant
            hoveredBackground: colors.primary.alpha(0.15)
            downBackground: colors.primary.alpha(0.3)
            downForeground: colors.primary

            cursorShape: Qt.PointingHandCursor

            onClicked: headerRoot.isSearching = !headerRoot.isSearching
        }

        // 4. زر الحذف (Clear All) باستخدام MButton المخصص
        MButton {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter

            showIcon: true
            iconText: "󰆴"
            text: ""
            textPreferredWidth: 0
            iconPreferredWidth: 16

            // الألوان (استخدام لون الخطأ error)
            normalBackground: "transparent"
            normalForeground: colors.onSurfaceVariant
            hoveredBackground: colors.error.alpha(0.15)
            downBackground: colors.error.alpha(0.3)
            downForeground: colors.error

            cursorShape: Qt.PointingHandCursor

            onClicked: headerRoot.clearAllClicked()
        }
    }
}

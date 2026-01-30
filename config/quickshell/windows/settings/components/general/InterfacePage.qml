// windows/settings/pages/InterfacePage.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform

import "root:/components"
import "root:/windows/settings/components"
import "root:/config"
import "root:/config/ConstValues.js" as C

BaseGeneralSettings {
    id: page
    title: qsTr("Workspace & Layout")
    icon: ""

    property var theme: page.selectedTheme

    // =========================================================
    // 1. المتغيرات المحلية
    // =========================================================
    property string localMenuStyle: C.FLOATING
    property bool localUseBottomLauncher: false
    property int localBottomLauncherWidth: 800

    // متغيرات ودجت عنوان النافذة
    property int localTopBarActiveWindowMaxWidth: 350
    property int localTopBarActiveWindowMinWidth: 150

    // متغيرات مساحات العمل
    property bool localDynamicWorkspaces: false
    property string localActiveIconsString: ""
    property string localInactiveIconsString: ""

    // القيم الافتراضية
    readonly property var defaultActiveIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰭹", "󱍙", "󰺵", "󱋡", "󰙨"]
    readonly property var defaultInactiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰻞", "󱍚", "󰺶", "󱋢", "󰤑"]

    readonly property var menuStyleOptions: [qsTr("Floating (Overlay)"), qsTr("Docked - Icons Fixed Left"), qsTr("Docked - Push Content Right")]

    // =========================================================
    // 2. المزامنة (Read)
    // =========================================================
    function syncFromConfig() {
        localMenuStyle = App.menuStyle || C.FLOATING;
        localUseBottomLauncher = App.useBottomLauncher;
        localBottomLauncherWidth = App.bottomLauncherWidth || 800;

        localTopBarActiveWindowMaxWidth = App.topBarActiveWindowMaxWidth || 350;
        localTopBarActiveWindowMinWidth = App.topBarActiveWindowMinWidth || 150;

        localDynamicWorkspaces = App.dynamicWorkspaces;

        // تحويل المصفوفات إلى نصوص
        var activeArr = (App.activeWorkspacesIcons && App.activeWorkspacesIcons.length > 0) ? App.activeWorkspacesIcons : defaultActiveIcons;
        var inactiveArr = (App.inActiveWorkspacesIcons && App.inActiveWorkspacesIcons.length > 0) ? App.inActiveWorkspacesIcons : defaultInactiveIcons;

        localActiveIconsString = activeArr.join(",");
        localInactiveIconsString = inactiveArr.join(",");
    }

    // =========================================================
    // 3. التجهيز للحفظ (Write)
    // =========================================================
    function serializeData() {
        var activeArr = localActiveIconsString.split(",").map(s => s.trim()).filter(s => s !== "");
        var inactiveArr = localInactiveIconsString.split(",").map(s => s.trim()).filter(s => s !== "");

        return {
            "menuStyle": localMenuStyle,
            "useBottomLauncher": localUseBottomLauncher,
            "bottomLauncherWidth": localBottomLauncherWidth,
            "topBarActiveWindowMaxWidth": localTopBarActiveWindowMaxWidth,
            "topBarActiveWindowMinWidth": localTopBarActiveWindowMinWidth,
            "dynamicWorkspaces": localDynamicWorkspaces,
            "activeWorkspacesIcons": activeArr,
            "inActiveWorkspacesIcons": inactiveArr
        };
    }

    // =========================================================
    // 4. الواجهة
    // =========================================================
    ColumnLayout {
        spacing: theme.dimensions.spacingLarge
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        // --- FORM CONTENT ---
        GridLayout {
            Layout.preferredWidth: 600
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            rowSpacing: 20
            columnSpacing: 20

            // ==========================
            // Section 1: Sidebar Style
            // ==========================
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: ""
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Sidebar Behavior")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }
            Controls.Label {
                text: qsTr("Menu Style")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
            }
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: page.menuStyleOptions
                currentIndex: {
                    if (page.localMenuStyle === C.DOCKED_FIXED_BAR)
                        return 1;
                    if (page.localMenuStyle === C.DOCKED_MOVING_BAR)
                        return 2;
                    return 0;
                }
                onActivated: index => {
                    if (index === 1)
                        page.localMenuStyle = C.DOCKED_FIXED_BAR;
                    else if (index === 2)
                        page.localMenuStyle = C.DOCKED_MOVING_BAR;
                    else
                        page.localMenuStyle = C.FLOATING;
                }
            }

            // ==========================
            // Section 2: Bottom Launcher
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: ""
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Launcher Layout")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }
            Controls.Label {
                text: qsTr("Bottom Bar Mode")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
            }
            SettingSwitch {
                isChecked: page.localUseBottomLauncher
                onIsCheckedChanged: page.localUseBottomLauncher = isChecked
            }

            Controls.Label {
                text: qsTr("Bar Width")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                visible: page.localUseBottomLauncher
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: page.localUseBottomLauncher
                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Px")
                    from: 550
                    to: 2000
                    stepSize: 10
                    decimals: 0
                    value: page.localBottomLauncherWidth
                    onEditingFinished: val => {
                        page.localBottomLauncherWidth = val;
                    }
                }
            }

            // ==========================
            // Section 3: Active Window Title Widget (Top Bar)
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: ""
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Active Window Title")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }

            // Max Width
            Controls.Label {
                text: qsTr("Max Width")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
            }
            ColumnLayout {
                Layout.fillWidth: true
                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Px")
                    from: 200
                    to: 800
                    stepSize: 10
                    decimals: 0
                    value: page.localTopBarActiveWindowMaxWidth
                    onEditingFinished: val => {
                        page.localTopBarActiveWindowMaxWidth = val;
                    }
                }
            }

            // Min Width
            Controls.Label {
                text: qsTr("Min Width")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
            }
            ColumnLayout {
                Layout.fillWidth: true
                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Px")
                    from: 50
                    to: 400
                    stepSize: 10
                    decimals: 0
                    value: page.localTopBarActiveWindowMinWidth
                    onEditingFinished: val => {
                        page.localTopBarActiveWindowMinWidth = val;
                    }
                }
                Text {
                    text: qsTr("Control the width of the active window title displayed in the top bar.")
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                    wrapMode: Text.WordWrap
                }
            }

            // ==========================
            // Section 4: Workspaces Behavior
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: ""
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Workspaces Behavior")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }

            Controls.Label {
                text: qsTr("Dynamic Workspaces")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
            }
            ColumnLayout {
                Layout.fillWidth: true
                enabled: false
                SettingSwitch {
                    isChecked: page.localDynamicWorkspaces
                    onIsCheckedChanged: page.localDynamicWorkspaces = isChecked
                    tooltip: qsTr("If enabled, icon settings are hidden and managed automatically.")
                }
                Text {
                    // text: page.localDynamicWorkspaces ? qsTr("Icons are managed dynamically (Auto-hidden).") : qsTr("Fixed icons are used. Define them below.")
                    text: "soon"
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                    wrapMode: Text.WordWrap
                }
            }

            // Active Icons (Visible only if NOT dynamic)
            Controls.Label {
                text: qsTr("Active Icons")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
                visible: !page.localDynamicWorkspaces
            }
            ColumnLayout {
                Layout.fillWidth: true
                visible: !page.localDynamicWorkspaces
                Controls.TextField {
                    Layout.fillWidth: true
                    text: page.localActiveIconsString
                    placeholderText: "Icon1,Icon2,Icon3..."
                    font.family: theme.typography.iconFont
                    onTextChanged: page.localActiveIconsString = text
                }
                Text {
                    text: qsTr("Comma separated icons.")
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                }
            }

            // Inactive Icons (Visible only if NOT dynamic)
            Controls.Label {
                text: qsTr("Inactive Icons")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
                visible: !page.localDynamicWorkspaces
            }
            ColumnLayout {
                Layout.fillWidth: true
                visible: !page.localDynamicWorkspaces
                Controls.TextField {
                    Layout.fillWidth: true
                    text: page.localInactiveIconsString
                    placeholderText: "Icon1,Icon2,Icon3..."
                    font.family: theme.typography.iconFont
                    onTextChanged: page.localInactiveIconsString = text
                }
                Text {
                    text: qsTr("Comma separated icons.")
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

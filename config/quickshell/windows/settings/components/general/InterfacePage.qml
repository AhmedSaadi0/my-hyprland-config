// windows/settings/pages/InterfacePage.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform
import "root:/components"
import "root:/components/settings"
import "root:/windows/settings/components"
import "root:/config"
import "root:/config/ConstValues.js" as C

BaseGeneralSettings {
    id: page
    title: qsTr("Workspace & Layout")
    icon: ""
    property var theme: page.selectedTheme
    property string localMenuStyle: C.FLOATING
    property int localBottomLauncherWidth: 800
    property int localTopBarActiveWindowMaxWidth: 350
    property int localTopBarActiveWindowMinWidth: 150
    property bool localDynamicWorkspaces: false
    property string localActiveIconsString: ""
    property string localInactiveIconsString: ""
    readonly property var defaultActiveIcons: ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰭹", "󱍙", "󰺵", "󱋡", "󰙨"]
    readonly property var defaultInactiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰻞", "󱍚", "󰺶", "󱋢", "󰤑"]
    readonly property var menuStyleOptions: [qsTr("Floating (Overlay)"), qsTr("Docked - Icons Fixed Left"), qsTr("Docked - Push Content Right")]
    function syncFromConfig() {
        localMenuStyle = App.menuStyle || C.FLOATING;
        localBottomLauncherWidth = App.bottomLauncherWidth || 800;
        localTopBarActiveWindowMaxWidth = App.topBarActiveWindowMaxWidth || 350;
        localTopBarActiveWindowMinWidth = App.topBarActiveWindowMinWidth || 150;
        localDynamicWorkspaces = App.dynamicWorkspaces;
        var activeArr = (App.activeWorkspacesIcons && App.activeWorkspacesIcons.length > 0) ? App.activeWorkspacesIcons : defaultActiveIcons;
        var inactiveArr = (App.inActiveWorkspacesIcons && App.inActiveWorkspacesIcons.length > 0) ? App.inActiveWorkspacesIcons : defaultInactiveIcons;
        localActiveIconsString = activeArr.join(",");
        localInactiveIconsString = inactiveArr.join(",");
    }
    function serializeData() {
        var activeArr = localActiveIconsString.split(",").map(s => s.trim()).filter(s => s !== "");
        var inactiveArr = localInactiveIconsString.split(",").map(s => s.trim()).filter(s => s !== "");
        return {
            "menuStyle": localMenuStyle,
            "bottomLauncherWidth": localBottomLauncherWidth,
            "topBarActiveWindowMaxWidth": localTopBarActiveWindowMaxWidth,
            "topBarActiveWindowMinWidth": localTopBarActiveWindowMinWidth,
            "dynamicWorkspaces": localDynamicWorkspaces,
            "activeWorkspacesIcons": activeArr,
            "inActiveWorkspacesIcons": inactiveArr
        };
    }
    ColumnLayout {
        spacing: theme.dimensions.spacingLarge
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        SectionCard {
            Layout.preferredWidth: 600
            title: qsTr("Sidebar Behavior")
            Controls.Label {
                text: qsTr("Menu Style")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
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
        }
        SectionCard {
            Layout.preferredWidth: 600
            title: qsTr("Launcher Width")
            Controls.Label {
                text: qsTr("Bar Width")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
            }
            SliderWithLabel {
                Layout.fillWidth: true
                label: qsTr("Px")
                from: 550
                to: 2000
                stepSize: 10
                decimals: 0
                value: page.localBottomLauncherWidth
                onEditingFinished: val => page.localBottomLauncherWidth = val
            }
        }
        SectionCard {
            Layout.preferredWidth: 600
            title: qsTr("Active Window Title")
            Controls.Label {
                text: qsTr("Max Width")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
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
                    onEditingFinished: val => page.localTopBarActiveWindowMaxWidth = val
                }
            }
            Controls.Label {
                text: qsTr("Min Width")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
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
                    onEditingFinished: val => page.localTopBarActiveWindowMinWidth = val
                }
                Text {
                    text: qsTr("Control the width of the active window title displayed in the top bar.")
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.onSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }
        }
        SectionCard {
            Layout.preferredWidth: 600
            title: qsTr("Workspaces Behavior")
            Controls.Label {
                text: qsTr("Dynamic Workspaces")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
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
                    text: "soon"
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.onSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }
            Controls.Label {
                text: qsTr("Active Icons")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                visible: !page.localDynamicWorkspaces
                Layout.topMargin: 8
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
                    color: theme.colors.onSurfaceVariant
                }
            }
            Controls.Label {
                text: qsTr("Inactive Icons")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                visible: !page.localDynamicWorkspaces
                Layout.topMargin: 8
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
                    color: theme.colors.onSurfaceVariant
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}

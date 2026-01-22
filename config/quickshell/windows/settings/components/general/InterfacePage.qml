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

    // خيارات القائمة للعرض
    readonly property var menuStyleOptions: [qsTr("Floating (Overlay)")          // Index 0
        , qsTr("Docked - Icons Fixed Left")   // Index 1
        , qsTr("Docked - Push Content Right")  // Index 2
    ]

    // =========================================================
    // 2. المزامنة (Read)
    // =========================================================
    function syncFromConfig() {
        localMenuStyle = App.menuStyle || C.FLOATING;
        localUseBottomLauncher = App.useBottomLauncher;
        localBottomLauncherWidth = App.bottomLauncherWidth || 800;
    }

    // =========================================================
    // 3. التجهيز للحفظ (Write)
    // =========================================================
    function serializeData() {
        return {
            "menuStyle": localMenuStyle,
            "useBottomLauncher": localUseBottomLauncher,
            "bottomLauncherWidth": localBottomLauncherWidth
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
                    text: "" // Grid/Menu Icon
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

            // Menu Style Selection
            Controls.Label {
                text: qsTr("Menu Style")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                SettingsComboBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: page.menuStyleOptions

                    // تحديد الإندكس بناءً على القيمة المحفوظة
                    currentIndex: {
                        if (page.localMenuStyle === C.DOCKED_FIXED_BAR)
                            return 1;
                        if (page.localMenuStyle === C.DOCKED_MOVING_BAR)
                            return 2;
                        return 0; // Floating
                    }

                    // عند الاختيار نحدث المتغير بالقيمة الثابتة (Internal String)
                    onActivated: index => {
                        if (index === 1)
                            page.localMenuStyle = C.DOCKED_FIXED_BAR;
                        else if (index === 2)
                            page.localMenuStyle = C.DOCKED_MOVING_BAR;
                        else
                            page.localMenuStyle = C.FLOATING;
                    }
                }

                // Description Text
                Text {
                    text: {
                        if (page.localMenuStyle === C.DOCKED_FIXED_BAR)
                            return qsTr("Menu reserves space. Icons stay fixed on the left.");
                        if (page.localMenuStyle === C.DOCKED_MOVING_BAR)
                            return qsTr("Menu reserves space. Content pushes to the right.");
                        return qsTr("Menu floats above windows (Overlay).");
                    }
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
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
                    text: "" // Dock/Bottom Icon
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

            // Enable Bottom Launcher
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
                tooltip: qsTr("Disable side launcher and use a bottom dock style.")
            }

            // Launcher Width (Visible only if enabled)
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

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Slider {
                        Layout.fillWidth: true
                        from: 550
                        to: 1200
                        stepSize: 10
                        value: page.localBottomLauncherWidth
                        onMoved: page.localBottomLauncherWidth = value
                    }
                    Text {
                        text: page.localBottomLauncherWidth + " px"
                        font.family: theme.typography.bodyFont
                        color: theme.colors.subtleText
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Text {
                    text: qsTr("Adjust the width of the bottom launcher.")
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

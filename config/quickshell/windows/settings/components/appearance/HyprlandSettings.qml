// windows/settings/HyprlandSettings.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Qt.labs.platform

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    // --- Header ---
    title: qsTr("Hyprland Settings")
    icon: ""
    showApplyButton: true

    // --- Local State ---
    // Layout
    property int localRounding: 0
    property int localBorderWidth: 0
    property int localGapsIn: 0
    property string localGapsOut: "0"
    property string localLayout: "dwindle"
    property string localActiveBorder: ""
    property string localInactiveBorder: ""

    // Visual Effects
    property bool localBlurEnabled: true
    property int localBlurSize: 1
    property int localBlurPasses: 1

    property bool localDropShadow: false
    property int localShadowRange: 0
    property int localShadowOffsetX: 0
    property int localShadowOffsetY: 0
    property string localShadowColor: ""

    property bool localDimInactive: false
    property double localDimStrength: 0.0

    // Animations
    property bool localAnimationsEnabled: true
    // property string localBezier: ""
    // property string localAnimWindows: ""
    // property string localAnimWorkspaces: ""

    function syncFromTheme() {
        // Layout
        localRounding = theme._hyprRounding;
        localBorderWidth = theme._hyprBorderWidth;
        localGapsIn = theme._hyprGapsIn;
        localGapsOut = theme._hyprGapsOut;
        localLayout = theme._hyprLayout;
        localActiveBorder = theme._hyprActiveBorder;
        localInactiveBorder = theme._hyprInactiveBorder;

        // Blur
        localBlurEnabled = theme._hyprBlurEnabled;
        localBlurSize = theme._hyprBlurSize;
        localBlurPasses = theme._hyprBlurPasses;

        localDropShadow = (theme._hyprDropShadow === 'yes' || theme._hyprDropShadow === true);
        localShadowRange = theme._hyprShadowRange;
        localShadowOffsetX = theme._hyprShadowOffset.x;
        localShadowOffsetY = theme._hyprShadowOffset.y;
        localShadowColor = theme._hyprShadowColor;

        // Dim
        localDimInactive = theme._hyprDimInactive;
        localDimStrength = theme._hyprDimStrength;

        // Animations
        localAnimationsEnabled = theme._hyprAnimationsEnabled;
    }

    function serializeData() {
        return {
            // Layout
            "_hyprRounding": localRounding,
            "_hyprBorderWidth": localBorderWidth,
            "_hyprGapsIn": localGapsIn,
            "_hyprGapsOut": localGapsOut,
            "_hyprLayout": localLayout,
            "_hyprActiveBorder": localActiveBorder,
            "_hyprInactiveBorder": localInactiveBorder,

            // Visual Effects
            "_hyprBlurEnabled": localBlurEnabled,
            "_hyprBlurSize": localBlurSize,
            "_hyprBlurPasses": localBlurPasses,
            "_hyprDropShadow": localDropShadow ? 'yes' : 'no',
            "_hyprShadowRange": localShadowRange,
            "_hyprShadowOffset": Qt.point(localShadowOffsetX, localShadowOffsetY),
            "_hyprShadowColor": localShadowColor,
            "_hyprDimInactive": localDimInactive,
            "_hyprDimStrength": localDimStrength,

            // Animations
            "_hyprAnimationsEnabled": localAnimationsEnabled
        };
    }

    // --- Main Layout ---
    ColumnLayout {
        spacing: root.dim("spacingSmall", 5)
        Layout.preferredWidth: 590

        // ==========================
        // --- Appearance & Layout ---
        // ==========================
        Controls.Label {
            text: qsTr("Appearance & Layout")
            font.pixelSize: root.typ("heading2Size", 18)
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 15

            SliderWithLabel {
                label: qsTr("Rounding")
                from: 0
                to: 50
                value: root.localRounding
                onEditingFinished: v => {
                    root.localRounding = v;
                    root.applySingleProperty("_hyprRounding", v);
                }
            }
            SliderWithLabel {
                label: qsTr("Border Width")
                from: 0
                to: 10
                value: root.localBorderWidth
                onEditingFinished: v => {
                    root.localBorderWidth = v;
                    root.applySingleProperty("_hyprBorderWidth", v);
                }
            }
            SliderWithLabel {
                label: qsTr("Gaps In")
                from: 0
                to: 50
                value: root.localGapsIn
                onEditingFinished: v => {
                    root.localGapsIn = v;
                    root.applySingleProperty("_hyprGapsIn", v);
                }
            }

            // Gaps Out
            ColumnLayout {
                spacing: 2
                Controls.Label {
                    text: qsTr("Gaps Out")
                    font.bold: true
                }
                SettingsHelperText {
                    text: qsTr("The gap between windows and the screen edge. Can be one value, or four (top, right, bottom, left).")
                }
                EditableField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    text: root.localGapsOut
                    selectedTheme: root.theme
                    onEditingFinished: {
                        root.localGapsOut = text;
                        root.applySingleProperty("_hyprGapsOut", text);
                    }
                }
            }

            // Layout Name
            ColumnLayout {
                spacing: 2
                Controls.Label {
                    text: qsTr("Layout Name")
                    font.bold: true
                }
                SettingsHelperText {
                    text: qsTr("'dwindle' (spiral) or 'master' (stack).")
                }
                SettingsComboBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: ["dwindle", "master"]
                    editText: root.localLayout
                    editable: true
                    onAccepted: {
                        if (editText !== root.localLayout) {
                            root.localLayout = editText;
                            root.applySingleProperty("_hyprLayout", editText);
                        }
                    }
                }
            }

            // Borders
            ColumnLayout {
                spacing: 2
                Controls.Label {
                    text: qsTr("Active Border Color")
                    font.bold: true
                }
                SettingsHelperText {
                    text: qsTr("Supports gradients. Ex: 'rgba(ff0000ff) rgba(00ff00ff) 45deg'.")
                }
                EditableField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    text: root.localActiveBorder
                    selectedTheme: root.theme
                    onEditingFinished: {
                        root.localActiveBorder = text;
                        root.applySingleProperty("_hyprActiveBorder", text);
                    }
                }
            }

            ColumnLayout {
                spacing: 2
                Controls.Label {
                    text: qsTr("Inactive Border Color")
                    font.bold: true
                }
                EditableField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    text: root.localInactiveBorder
                    selectedTheme: root.theme
                    onEditingFinished: {
                        root.localInactiveBorder = text;
                        root.applySingleProperty("_hyprInactiveBorder", text);
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 15
        }

        // ==========================
        // --- Visual Effects ---
        // ==========================
        Controls.Label {
            text: qsTr("Visual Effects")
            font.pixelSize: root.typ("heading2Size", 18)
            font.bold: true
            Layout.topMargin: 10
        }

        // Blur
        SettingSwitch {
            id: _blurSwitch
            label: qsTr("Enable Background Blur")
            isChecked: root.localBlurEnabled
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localBlurEnabled = isChecked;
                root.applySingleProperty("_hyprBlurEnabled", isChecked);
            }
        }

        ColumnLayout {
            enabled: root.localBlurEnabled
            Layout.fillWidth: true
            Layout.leftMargin: 20
            spacing: 15

            SliderWithLabel {
                label: qsTr("Blur Size")
                from: 1
                to: 30
                value: root.localBlurSize
                onEditingFinished: v => {
                    root.localBlurSize = v;
                    root.applySingleProperty("_hyprBlurSize", v);
                }
            }
            SliderWithLabel {
                label: qsTr("Blur Passes")
                from: 1
                to: 5
                value: root.localBlurPasses
                onEditingFinished: v => {
                    root.localBlurPasses = v;
                    root.applySingleProperty("_hyprBlurPasses", v);
                }
            }
            SettingsHelperText {
                text: qsTr("2-3 passes is a good balance between quality and performance.")
            }
        }

        // Shadow
        SettingSwitch {
            id: _dropShadowSwitch
            label: qsTr("Enable Drop Shadow")
            isChecked: root.localDropShadow
            Layout.topMargin: 10
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localDropShadow = isChecked;
                // تحويل القيمة البوليانية إلى النص المتوقع في Hyprland
                root.applySingleProperty("_hyprDropShadow", isChecked ? 'yes' : 'no');
            }
        }

        ColumnLayout {
            enabled: root.localDropShadow
            Layout.fillWidth: true
            Layout.leftMargin: 20
            spacing: 15

            SliderWithLabel {
                label: qsTr("Shadow Range")
                from: 0
                to: 60
                value: root.localShadowRange
                onEditingFinished: v => {
                    root.localShadowRange = v;
                    root.applySingleProperty("_hyprShadowRange", v);
                }
            }

            ColumnLayout {
                spacing: 5
                Controls.Label {
                    text: qsTr("Shadow Offset (X, Y)")
                    font.bold: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    EditableField {
                        Layout.fillWidth: true
                        text: root.localShadowOffsetX.toString()
                        validator: IntValidator {}
                        selectedTheme: root.theme
                        onEditingFinished: {
                            root.localShadowOffsetX = Number(text);
                            // إرسال كائن Point كامل لأن ThemeManager يتوقع ذلك
                            root.applySingleProperty("_hyprShadowOffset", Qt.point(root.localShadowOffsetX, root.localShadowOffsetY));
                        }
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: root.localShadowOffsetY.toString()
                        validator: IntValidator {}
                        selectedTheme: root.theme
                        onEditingFinished: {
                            root.localShadowOffsetY = Number(text);
                            // إرسال كائن Point كامل
                            root.applySingleProperty("_hyprShadowOffset", Qt.point(root.localShadowOffsetX, root.localShadowOffsetY));
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 5
                Controls.Label {
                    text: qsTr("Shadow Color")
                    font.bold: true
                }
                EditableField {
                    Layout.fillWidth: true
                    text: root.localShadowColor
                    selectedTheme: root.theme
                    onEditingFinished: {
                        root.localShadowColor = text;
                        root.applySingleProperty("_hyprShadowColor", text);
                    }
                }
            }
        }

        // Dim
        SettingSwitch {
            id: _dimSwitch
            label: qsTr("Dim Inactive Windows")
            isChecked: root.localDimInactive
            Layout.topMargin: 10
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localDimInactive = isChecked;
                root.applySingleProperty("_hyprDimInactive", isChecked);
            }
        }

        ColumnLayout {
            enabled: root.localDimInactive
            Layout.fillWidth: true
            Layout.leftMargin: 20

            SliderWithLabel {
                label: qsTr("Dim Strength")
                from: 0.0
                to: 1.0
                stepSize: 0.01
                decimals: 2
                value: root.localDimStrength
                onEditingFinished: v => {
                    root.localDimStrength = v;
                    root.applySingleProperty("_hyprDimStrength", v);
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 15
        }

        // ==========================
        // --- Animations ---
        // ==========================
        SettingSwitch {
            id: _animationsSwitch
            label: qsTr("Enable Animations")
            isChecked: root.localAnimationsEnabled
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localAnimationsEnabled = isChecked;
                root.applySingleProperty("_hyprAnimationsEnabled", isChecked);
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
            width: 1
        }
    }
}

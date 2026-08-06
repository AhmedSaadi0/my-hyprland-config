// windows/settings/monitors/MonitorItem.qml
// بطاقة شاشة واحدة: معلومات + تحكمات الدقة والمقياس والدوران والموضع والمرآة

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/components"
import "root:/components/settings"
import "root:/themes"

Rectangle {
    id: root

    // كائن الشاشة الحالي القادم من hyprctl monitors all -j
    property var monitor
    // كل الشاشات (لاستخراج أسماء أهداف المرايا)
    property var allMonitors: []
    property var selectedTheme

    // إشارات تطبقها الصفحة الأم
    signal applyRule(string name, string res, string pos, string scale, string extra)
    signal placeRelative(string name, string side)
    signal runCommand(var argv)
    signal requestRefresh

    // يمنع الأحداث أثناء مزامنة الواجهة مع البيانات
    property bool blockUi: false

    // لقطة للقاعدة قبل تطبيق المرآة (لا يمكن الوثوق بقيم JSON أثناء المرآة)
    property var preMirrorRule: null

    // =========================================================
    // 1. خصائص محسوبة
    // =========================================================

    readonly property bool isMirror: typeof monitor?.mirrorOf === "number"
    readonly property bool isDisabled: !!monitor?.disabled
    readonly property bool isFocused: !!monitor?.focused
    readonly property string mirrorSource: {
        if (!isMirror || !monitor)
            return "";
        const src = allMonitors.find(m => m.id === monitor.mirrorOf);
        return src ? src.name : "";
    }
    readonly property string currentNormalized: {
        if (!monitor || !monitor.width || !monitor.refreshRate)
            return "";
        return `${monitor.width}x${monitor.height}@${Number(monitor.refreshRate).toFixed(2)}`;
    }
    readonly property var resolutionModes: {
        if (!monitor || !Array.isArray(monitor.availableModes))
            return ["Preferred"];
        return ["Preferred"].concat(monitor.availableModes);
    }
    readonly property var mirrorTargets: {
        if (!allMonitors || !monitor)
            return [];
        return allMonitors.filter(m => m.name !== monitor.name && !m.disabled).map(m => m.name);
    }
    readonly property string physSize: {
        if (!monitor || !monitor.physicalWidth || !monitor.physicalHeight)
            return "";
        return `${monitor.physicalWidth} x ${monitor.physicalHeight} cm`;
    }
    readonly property string workspaceId: monitor?.activeWorkspace?.id ?? ""

    // قاعدة الحفاظ على الدقة والموضع الحاليين عند التعديل الجزئي
    function baseRes() {
        if (isMirror || !monitor?.width)
            return "preferred";
        return currentNormalized;
    }
    function basePos() {
        if (isMirror || monitor?.x === undefined)
            return "auto";
        return `${monitor.x}x${monitor.y}`;
    }
    function applyWithExtra(extra) {
        applyRule(monitor.name, baseRes(), basePos(), String(monitor.scale), extra || "");
    }

    // بدء المرآة: نحفظ اللقطة أولاً ثم نطبق قاعدة مرآة بسيطة
    function applyMirror(targetName) {
        if (!preMirrorRule)
            preMirrorRule = {
                res: baseRes(),
                pos: basePos(),
                scale: String(monitor.scale || 1)
            };
        applyRule(monitor.name, "preferred", "auto", "auto", `mirror,${targetName}`);
    }

    // إلغاء المرآة: استعادة القاعدة المحفوظة (أو الحالية إن لم تتوفر لقطة)
    function unmirror() {
        if (preMirrorRule) {
            applyRule(monitor.name, preMirrorRule.res, preMirrorRule.pos, preMirrorRule.scale, "");
            preMirrorRule = null;
        } else {
            applyRule(monitor.name, baseRes(), basePos(), String(monitor.scale || 1), "");
        }
    }

    // إيجاد أقرب مقياس متاح للقائمة
    function nearestScaleIndex(value) {
        const scales = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];
        let best = 0;
        let bestDiff = Number.MAX_VALUE;
        for (let i = 0; i < scales.length; i++) {
            const diff = Math.abs(scales[i] - value);
            if (diff < bestDiff) {
                bestDiff = diff;
                best = i;
            }
        }
        return best;
    }

    function syncFromMonitor() {
        blockUi = true;

        // الدقة
        let resIndex = 0;
        for (let i = 1; i < resolutionModes.length; i++) {
            const mode = String(resolutionModes[i]).replace(/Hz\s*$/i, "");
            if (mode === currentNormalized) {
                resIndex = i;
                break;
            }
        }
        resCombo.currentIndex = resIndex;

        // المقياس والدوران و VRR
        scaleCombo.currentIndex = nearestScaleIndex(Number(monitor?.scale || 1));
        const transformIndex = [0, 1, 2, 3].indexOf(Number(monitor?.transform || 0));
        transformCombo.currentIndex = Math.max(0, transformIndex);
        vrrCombo.currentIndex = Math.max(0, [0, 1, 2].indexOf(Number(monitor?.vrr || 0)));

        // المرآة
        let mirrorIndex = 0;
        if (isMirror) {
            const idx = mirrorTargets.indexOf(mirrorSource);
            mirrorIndex = idx >= 0 ? idx + 1 : 0;
        }
        mirrorCombo.currentIndex = mirrorIndex;

        // حقول الموضع
        xField.text = String(monitor?.x ?? 0);
        yField.text = String(monitor?.y ?? 0);

        // السويتشات: ضبط يدوي داخل الحماية حتى لا يطبّق أي أمر تلقائياً
        enabledSwitch.isChecked = !isDisabled;
        dpmsSwitch.isChecked = !!monitor?.dpmsStatus;

        // لقطة المرآة خاصة بالشاشة الحالية فقط
        preMirrorRule = null;

        blockUi = false;
    }

    onMonitorChanged: syncFromMonitor()

    // =========================================================
    // 2. الشكل
    // =========================================================

    width: 610
    implicitHeight: contentLayout.implicitHeight + 40
    radius: selectedTheme.dimensions.elementRadius
    color: selectedTheme.colors.surfaceContainer

    Behavior on border.width {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    border.width: isFocused ? 2 : 0
    border.color: isFocused ? selectedTheme.colors.primary : "transparent"

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ---- صف الهوية ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰍹"
                font.family: selectedTheme.typography.iconFont
                font.pixelSize: 20
                color: selectedTheme.colors.primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: monitor?.name || ""
                        color: selectedTheme.colors.onSurface
                        font.bold: true
                        font.pixelSize: 16
                    }

                    // شارة Focused
                    Rectangle {
                        visible: isFocused
                        Layout.preferredHeight: 18
                        implicitWidth: focusedBadgeText.implicitWidth + 12
                        radius: 9
                        color: selectedTheme.colors.primary
                        Text {
                            id: focusedBadgeText
                            anchors.centerIn: parent
                            text: qsTr("Focused")
                            color: selectedTheme.colors.onPrimary
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    // شارة Disabled
                    Rectangle {
                        visible: isDisabled
                        Layout.preferredHeight: 18
                        implicitWidth: disabledBadgeText.implicitWidth + 12
                        radius: 9
                        color: selectedTheme.colors.onSurfaceVariant.alpha(0.25)
                        Text {
                            id: disabledBadgeText
                            anchors.centerIn: parent
                            text: qsTr("Disabled")
                            color: selectedTheme.colors.onSurfaceVariant
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    // شارة Mirror
                    Rectangle {
                        visible: isMirror
                        Layout.preferredHeight: 18
                        implicitWidth: mirrorBadgeText.implicitWidth + 12
                        radius: 9
                        color: selectedTheme.colors.secondary
                        Text {
                            id: mirrorBadgeText
                            anchors.centerIn: parent
                            text: qsTr("Mirror of") + (mirrorSource ? " " + mirrorSource : "")
                            color: selectedTheme.colors.onSecondary
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                Text {
                    text: monitor?.description || monitor?.model || ""
                    color: selectedTheme.colors.onSurfaceVariant
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // مساحة العمل النشطة
            Text {
                visible: workspaceId !== ""
                text: qsTr("Workspace") + " " + workspaceId
                color: selectedTheme.colors.onSurfaceVariant
                font.pixelSize: 11
            }
        }

        // ---- شريط المعلومات ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: root.currentNormalized
                font.pixelSize: 12
                font.bold: true
                color: selectedTheme.colors.onSurface
            }
            Text {
                text: "•"
                color: selectedTheme.colors.onSurfaceVariant
            }
            Text {
                text: qsTr("Scale") + " " + Number(monitor?.scale || 1).toFixed(2) + "x"
                font.pixelSize: 12
                color: selectedTheme.colors.onSurfaceVariant
            }
            Text {
                visible: physSize !== ""
                text: "•"
                color: selectedTheme.colors.onSurfaceVariant
            }
            Text {
                visible: physSize !== ""
                text: qsTr("Size") + " " + physSize
                font.pixelSize: 12
                color: selectedTheme.colors.onSurfaceVariant
            }
        }

        // ---- تحكمات الدقة والمقياس والدوران و VRR والمرآة ----
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 10
            rowSpacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label {
                    text: qsTr("Resolution")
                    color: selectedTheme.colors.onSurfaceVariant
                    font.pixelSize: 11
                }
                SettingsComboBox {
                    id: resCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    model: root.resolutionModes
                    enabled: !isDisabled && !isMirror
                    onActivated: idx => {
                        if (root.blockUi)
                            return;
                        const mode = idx === 0 ? "preferred" : String(root.resolutionModes[idx]).replace(/Hz\s*$/i, "");
                        root.applyRule(root.monitor.name, mode, root.basePos(), String(root.monitor.scale), "");
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label {
                    text: qsTr("Scale")
                    color: selectedTheme.colors.onSurfaceVariant
                    font.pixelSize: 11
                }
                SettingsComboBox {
                    id: scaleCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    model: ["0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x", "2.5x", "3x"]
                    enabled: !isDisabled && !isMirror
                    onActivated: idx => {
                        if (root.blockUi)
                            return;
                        const scales = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];
                        root.applyRule(root.monitor.name, root.baseRes(), root.basePos(), String(scales[idx]), "");
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label {
                    text: qsTr("Rotation")
                    color: selectedTheme.colors.onSurfaceVariant
                    font.pixelSize: 11
                }
                SettingsComboBox {
                    id: transformCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    model: ["0°", "90°", "180°", "270°"]
                    enabled: !isDisabled && !isMirror
                    onActivated: idx => {
                        if (root.blockUi)
                            return;
                        root.applyWithExtra(`transform,${[0, 1, 2, 3][idx]}`);
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label {
                    text: qsTr("VRR")
                    color: selectedTheme.colors.onSurfaceVariant
                    font.pixelSize: 11
                }
                SettingsComboBox {
                    id: vrrCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    model: [qsTr("Off"), qsTr("On"), qsTr("Always")]
                    onActivated: idx => {
                        if (root.blockUi)
                            return;
                        root.applyWithExtra(`vrr,${[0, 1, 2][idx]}`);
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label {
                    text: qsTr("Mirror")
                    color: selectedTheme.colors.onSurfaceVariant
                    font.pixelSize: 11
                }
                SettingsComboBox {
                    id: mirrorCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    model: [qsTr("None")].concat(root.mirrorTargets)
                    enabled: !isDisabled
                    onActivated: idx => {
                        if (root.blockUi)
                            return;
                        if (idx === 0) {
                            // إلغاء المرآة: استعادة القاعدة المحفوظة قبل المرآة
                            root.unmirror();
                        } else {
                            root.applyMirror(root.mirrorTargets[idx - 1]);
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // ---- مفاتيح التفعيل و DPMS ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            SettingSwitch {
                id: enabledSwitch
                Layout.fillWidth: true
                label: qsTr("Monitor Enabled")
                // لا نربطها بالبيانات مباشرة — تُضبط يدوياً داخل syncFromMonitor
                isChecked: false
                onIsCheckedChanged: {
                    if (root.blockUi)
                        return;
                    if (isChecked) {
                        // إعادة تفعيل بقاعدة كاملة
                        root.applyRule(root.monitor.name, root.baseRes(), root.basePos(), String(root.monitor.scale || 1), "");
                    } else {
                        root.runCommand(["hyprctl", "keyword", "monitor", `${root.monitor.name},disabled`]);
                    }
                }
            }

            SettingSwitch {
                id: dpmsSwitch
                Layout.fillWidth: true
                label: qsTr("DPMS (Screen On)")
                isChecked: false
                onIsCheckedChanged: {
                    if (root.blockUi)
                        return;
                    root.runCommand(["hyprctl", "dispatch", "dpms", isChecked ? "on" : "off", root.monitor.name]);
                }
            }
        }

        // ---- الموضع: يمين / يسار / فوق / تحت + إحداثيات ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MButton {
                text: qsTr("Right")
                iconText: "→"
                iconFirst: false
                implicitWidth: 80
                normalBackground: selectedTheme.colors.secondaryContainer
                normalForeground: selectedTheme.colors.onSecondaryContainer
                enabled: !isDisabled && !isMirror
                onClicked: root.placeRelative(root.monitor.name, "right")
            }
            MButton {
                text: qsTr("Left")
                iconText: "←"
                iconFirst: false
                implicitWidth: 80
                normalBackground: selectedTheme.colors.secondaryContainer
                normalForeground: selectedTheme.colors.onSecondaryContainer
                enabled: !isDisabled && !isMirror
                onClicked: root.placeRelative(root.monitor.name, "left")
            }
            MButton {
                text: qsTr("Above")
                iconText: "↑"
                iconFirst: false
                implicitWidth: 80
                normalBackground: selectedTheme.colors.secondaryContainer
                normalForeground: selectedTheme.colors.onSecondaryContainer
                enabled: !isDisabled && !isMirror
                onClicked: root.placeRelative(root.monitor.name, "above")
            }
            MButton {
                text: qsTr("Below")
                iconText: "↓"
                iconFirst: false
                implicitWidth: 80
                normalBackground: selectedTheme.colors.secondaryContainer
                normalForeground: selectedTheme.colors.onSecondaryContainer
                enabled: !isDisabled && !isMirror
                onClicked: root.placeRelative(root.monitor.name, "below")
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: "X"
                color: selectedTheme.colors.onSurfaceVariant
            }
            EditableField {
                id: xField
                Layout.preferredWidth: 56
                Layout.preferredHeight: 28
                selectedTheme: root.selectedTheme
                validator: IntValidator {
                    bottom: -20000
                    top: 20000
                }
                enabled: !isDisabled && !isMirror
                onEditingFinished: {
                    if (root.blockUi)
                        return;
                    const x = parseInt(text, 10);
                    if (!isNaN(x) && x !== Number(root.monitor.x))
                        root.applyRule(root.monitor.name, root.baseRes(), `${x}x${root.monitor.y}`, String(root.monitor.scale), "");
                }
            }

            Label {
                text: "Y"
                color: selectedTheme.colors.onSurfaceVariant
            }
            EditableField {
                id: yField
                Layout.preferredWidth: 56
                Layout.preferredHeight: 28
                selectedTheme: root.selectedTheme
                validator: IntValidator {
                    bottom: -20000
                    top: 20000
                }
                enabled: !isDisabled && !isMirror
                onEditingFinished: {
                    if (root.blockUi)
                        return;
                    const y = parseInt(text, 10);
                    if (!isNaN(y) && y !== Number(root.monitor.y))
                        root.applyRule(root.monitor.name, root.baseRes(), `${root.monitor.x}x${y}`, String(root.monitor.scale), "");
                }
            }
        }

        // ---- أزرار إضافية ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MButton {
                text: qsTr("Focus This Monitor")
                implicitWidth: 180
                textPreferredWidth: 8
                iconText: "◎"
                iconFirst: true
                normalBackground: selectedTheme.colors.primaryContainer
                normalForeground: selectedTheme.colors.onPrimaryContainer
                enabled: !isDisabled
                onClicked: root.runCommand(["hyprctl", "dispatch", "focusmonitor", root.monitor.name])
            }

            Item {
                Layout.fillWidth: true
            }

            MButton {
                text: qsTr("Refresh")
                implicitWidth: 100
                iconText: "⟳"
                iconFirst: true
                normalBackground: selectedTheme.colors.surfaceContainerHighest
                normalForeground: selectedTheme.colors.onSurface
                onClicked: root.requestRefresh()
            }
        }
    }
}

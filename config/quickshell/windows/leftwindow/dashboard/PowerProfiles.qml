// windows/leftwindow/dashboard/PowerProfiles.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import org.kde.kirigami as Kirigami

import "root:/windows/smart_capsule/logic"
import "root:/themes"
import "root:/components"
import "root:/config/ConstValues.js" as Consts

MenuCard {
    id: root

    // --- Texts & Content ---
    title: qsTr("Power Profiles") // "وضع الاداء"
    icon: ""
    cardColor: ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.7)
    textColor: ThemeManager.selectedTheme.colors.onSecondaryContainer

    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 30

    property int buttonsRowSpacing: 7
    property int innerRadiusDiv: 3

    property string highPerformanceButtonLabel: qsTr("High")
    property string balancedButtonLabel: qsTr("Balanced")
    property string lowButtonLabel: qsTr("Low")

    // --- Power Profile Enums (from Quickshell.Services.UPower) ---
    readonly property int profileIndexPerformance: PowerProfile.Performance
    readonly property int profileIndexBalanced: PowerProfile.Balanced
    readonly property int profileIndexPowerSaver: PowerProfile.PowerSaver

    // -------------------------------------------------------------------------
    // --- State Properties
    // -------------------------------------------------------------------------
    property var selectedProfile: PowerProfiles.profile // Comes from UPower
    property bool _readyForNotifications: false
    property int _lastNotifiedProfile: -1
    property int _pendingProfile: -1
    property bool _pendingUserChange: false

    function _notifyProfileChange(profile) {
        CapsuleCoordinator.handlePowerProfileChange(profile);
    }

    function _notifyProfileError(message) {
        CapsuleCoordinator.handlePowerProfileError(message);
    }

    function _requestProfileChange(profile) {
        if (PowerProfiles.profile === profile)
            return;

        _pendingProfile = profile;
        _pendingUserChange = true;
        PowerProfiles.profile = profile;
        profileChangeTimer.restart();
    }

    onSelectedProfileChanged: {
        if (!_readyForNotifications) {
            _lastNotifiedProfile = selectedProfile;
            return;
        }

        if (selectedProfile === _lastNotifiedProfile)
            return;

        _lastNotifiedProfile = selectedProfile;

        if (_pendingUserChange && selectedProfile === _pendingProfile) {
            _pendingUserChange = false;
            profileChangeTimer.stop();
        }

        _notifyProfileChange(selectedProfile);
    }

    Component.onCompleted: {
        _readyForNotifications = true;
        _lastNotifiedProfile = selectedProfile;
    }

    Timer {
        id: profileChangeTimer
        interval: 2500
        repeat: false
        onTriggered: {
            if (_pendingUserChange && PowerProfiles.profile !== _pendingProfile) {
                _pendingUserChange = false;
                _notifyProfileError(qsTr("Failed to change power profile. Check system permissions."));
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        spacing: 6

        // -------------------------------------------------------------
        // حاوية الأزرار المنقسمة الموحدة (Segmented Buttons Container)
        // -------------------------------------------------------------
        Item {
            id: segmentedContainer
            Layout.fillWidth: true
            Layout.preferredHeight: root.defaultButtonHeight

            // رصد الزر النشط حالياً بناءً على وضع الطاقة الفعلي للنظام
            property var activeButton: {
                if (root.selectedProfile === root.profileIndexPerformance)
                    return highPerformanceButton;
                if (root.selectedProfile === root.profileIndexBalanced)
                    return balancedButton;
                if (root.selectedProfile === root.profileIndexPowerSaver)
                    return batterySavingButton;
                return null;
            }

            // إحداثيات ومقاييس الهدف للمحدد المنزلق
            property real targetX: activeButton ? activeButton.x : lastX
            property real targetY: activeButton ? activeButton.y : lastY
            property real targetWidth: activeButton ? activeButton.width : lastWidth
            property real targetHeight: activeButton ? activeButton.height : lastHeight

            // تخزين الذاكرة الحركية لتجنب قفزات الإحداثيات الصفرية عند التغييرات
            property real lastX: 0
            property real lastY: 0
            property real lastWidth: 100
            property real lastHeight: 30
            property bool showHighlight: activeButton !== null

            onActiveButtonChanged: {
                if (activeButton) {
                    lastX = activeButton.x;
                    lastY = activeButton.y;
                    lastWidth = activeButton.width;
                    lastHeight = activeButton.height;
                }
            }

            // -----------------------------------------------------------------
            // 1. خلفية التحديد المنزلق الذكي (Sliding Selection Highlight)
            // -----------------------------------------------------------------
            // يوضع كأول عنصر داخل الحاوية ليتم رسمه في الخلفية خلف نصوص الأزرار تماماً
            Rectangle {
                id: selectionHighlight
                x: segmentedContainer.targetX
                y: segmentedContainer.targetY
                width: segmentedContainer.targetWidth
                height: segmentedContainer.targetHeight

                // لون التحديد النشط القياسي في M3
                color: ThemeManager.selectedTheme.colors.primary

                // ربط الزوايا ديناميكياً لتتشكل وتتأقلم بسلاسة مع زوايا الزر النشط حالياً
                topLeftRadius: segmentedContainer.activeButton ? segmentedContainer.activeButton.topLeftRadius : 0
                topRightRadius: segmentedContainer.activeButton ? segmentedContainer.activeButton.topRightRadius : 0
                bottomLeftRadius: segmentedContainer.activeButton ? segmentedContainer.activeButton.bottomLeftRadius : 0
                bottomRightRadius: segmentedContainer.activeButton ? segmentedContainer.activeButton.bottomRightRadius : 0

                opacity: segmentedContainer.showHighlight ? 1.0 : 0.0

                // مزامنة انكماش الحركة والتفاعل مع الزر النشط
                scale: segmentedContainer.activeButton ? segmentedContainer.activeButton.scale : 1.0

                // انميشن انزلاق وتحجيم مرن وفخم (باستخدام Easing.OutQuint)
                Behavior on x {
                    enabled: segmentedContainer.showHighlight
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on y {
                    enabled: segmentedContainer.showHighlight
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on width {
                    enabled: segmentedContainer.showHighlight
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on height {
                    enabled: segmentedContainer.showHighlight
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                // انميشن تشكل وتحول زوايا المحدد أثناء التنقل
                Behavior on topLeftRadius {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on topRightRadius {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on bottomLeftRadius {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuint
                    }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            // 2. توزيع الأزرار (الطبقة الأمامية)
            RowLayout {
                id: widgetsRow
                anchors.fill: parent
                spacing: root.buttonsRowSpacing

                MButton {
                    id: highPerformanceButton
                    Layout.fillWidth: true
                    height: root.defaultButtonHeight
                    text: root.highPerformanceButtonLabel
                    onClicked: {
                        _requestProfileChange(PowerProfile.Performance);
                    }
                    enabled: PowerProfiles.hasPerformanceProfile
                    isActive: root.selectedProfile === root.profileIndexPerformance

                    // تحييد لون الخلفية النشط الأصلي للزر ليظهر المحدد المنزلق المشترك من الخلف
                    activeBackground: "transparent"

                    normalBackground: {
                        let base = ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.6);
                        return ThemeManager.selectedTheme._themeMode === "dark" ? Qt.lighter(base, 1.15) : Qt.darker(base, 1.12);
                    }

                    topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                    bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                }

                MButton {
                    id: balancedButton
                    Layout.fillWidth: true
                    height: root.defaultButtonHeight
                    text: root.balancedButtonLabel
                    onClicked: {
                        _requestProfileChange(PowerProfile.Balanced);
                    }
                    isActive: root.selectedProfile === root.profileIndexBalanced

                    // تحييد لون الخلفية النشط الأصلي للزر ليظهر المحدد المنزلق المشترك من الخلف
                    activeBackground: "transparent"

                    normalBackground: {
                        let base = ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.6);
                        return ThemeManager.selectedTheme._themeMode === "dark" ? Qt.lighter(base, 1.15) : Qt.darker(base, 1.12);
                    }

                    topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                    topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                    bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                    bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                }

                MButton {
                    id: batterySavingButton
                    Layout.fillWidth: true
                    height: root.defaultButtonHeight
                    text: root.lowButtonLabel
                    onClicked: {
                        _requestProfileChange(PowerProfile.PowerSaver);
                    }
                    isActive: root.selectedProfile === root.profileIndexPowerSaver

                    // تحييد لون الخلفية النشط الأصلي للزر ليظهر المحدد المنزلق المشترك من الخلف
                    activeBackground: "transparent"

                    normalBackground: {
                        let base = ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.6);
                        return ThemeManager.selectedTheme._themeMode === "dark" ? Qt.lighter(base, 1.15) : Qt.darker(base, 1.12);
                    }

                    bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                    topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: !PowerProfiles.hasPerformanceProfile

            Text {
                text: ""
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.onSecondaryContainer
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("High performance profile is not available on this device.")
                font.family: ThemeManager.selectedTheme.typography.bodyFont
                font.pixelSize: 11
                color: ThemeManager.selectedTheme.colors.onSecondaryContainer
                wrapMode: Text.Wrap
            }
        }
    }
}

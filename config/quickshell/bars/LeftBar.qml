// pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland

import "../themes"
import "../components"
import "root:/utils"
import "root:/services"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "root:/config/ConstValues.js" as Consts

PanelWindow {
    id: root

    implicitWidth: ThemeManager.selectedTheme.dimensions.leftBarWidth
    // color: ThemeManager.selectedTheme.colors.topbarColor
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        top: ThemeManager.selectedTheme.dimensions.barHeight
    }

    // --- Properties ---
    property bool panelOpen: false
    property int activeMenuIndex: LeftMenuStatus.selectedIndex
    property int notificationMenuIndex: -1

    Behavior on margins.left {
        NumberAnimation {
            duration: panelOpen ? 600 : 500
            easing.type: panelOpen ? Easing.OutExpo : Easing.OutCubic
        }
    }

    // ---------------------------------------------------------
    // 1. MODELS (البيانات)
    // ---------------------------------------------------------

    // [المجموعة العلوية - النظام]
    ListModel {
        id: topModel
        ListElement {
            icon: "󰨝"
            activeIcon: "󰕮"
            name: "Dashboard"
        }
        ListElement {
            icon: ""
            activeIcon: ""
            name: "Notifications"
            notificationCount: 0
        }
        ListElement {
            icon: ""
            activeIcon: "󰅟"
            name: "Weather"
        }
        ListElement {
            icon: ""
            activeIcon: ""
            name: "Monitors"
        }
        ListElement {
            icon: "󰤯"
            activeIcon: "󰤨"
            name: "Network"
        }
    }

    // [المجموعة الوسطى - الإنتاجية]
    ListModel {
        id: middleModel
        ListElement {
            icon: "󰅌"
            activeIcon: "󰅇"
            name: "Clipboard"
            notificationCount: 0
        }
        ListElement {
            icon: "󰢨"
            activeIcon: "󰅎"
            name: "Todo"
            notificationCount: 0
        }
        ListElement {
            icon: "󰊿"
            activeIcon: "󰗊"
            name: "Translator"
            notificationCount: 0
        }
        ListElement {
            icon: "󱙺"
            activeIcon: "󰚩"
            name: "AI Bot"
            notificationCount: 0
        }
    }

    // [المجموعة السفلية - التطبيقات]
    ListModel {
        id: bottomModel
        // ListElement {
        //     icon: ""
        //     activeIcon: ""
        //     name: "Favorites"
        //     notificationCount: 0
        // }
        ListElement {
            icon: "󰀻"
            activeIcon: "󰵆"
            name: "All Apps"
            notificationCount: 0
        }
        // --- ADDED POWER OPTION HERE ---
        ListElement {
            icon: ""           // Standard Power Icon
            activeIcon: ""     // Active state (can be red or filled if font supports it)
            name: "Power"
            notificationCount: 0
        }
    }

    // ---------------------------------------------------------
    // 2. LOGIC (المنطق)
    // ---------------------------------------------------------

    // حسابات الإزاحة (Offsets) لتوحيد الاندكس
    readonly property int middleOffset: topModel.count
    readonly property int bottomOffset: topModel.count + middleModel.count

    Connections {
        target: NotifManager
        function onNotificationCountChanged() {
            if (root.notificationMenuIndex !== -1) {
                topButtonGroup.model.set(root.notificationMenuIndex, {
                    "notificationCount": NotifManager.notificationCount
                });
            }
        }
    }

    Component.onCompleted: {
        // ربط الإشعارات
        for (let i = 0; i < topModel.count; i++) {
            if (topModel.get(i).name === "Notifications") {
                root.notificationMenuIndex = i;
                topModel.set(i, {
                    "notificationCount": NotifManager.notificationCount
                });
                break;
            }
        }

        EventBus.on(Events.LEFT_MENU_IS_CLOSED, function () {
            try {
                closePanel();
            } catch (error) {
                LeftMenuStatus.changeIndex(-1);
            }
            changeIsMenuOpen.start();
        });
    }

    // استقبال التغيير من الخارج وتوزيعه على المجموعة الصحيحة
    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex === -1) {
                topButtonGroup.currentIndex = -1;
                middleButtonGroup.currentIndex = -1;
                bottomButtonGroup.currentIndex = -1;
            } else
            // النطاق العلوي
            if (newIndex < root.middleOffset) {
                topButtonGroup.currentIndex = newIndex;
                middleButtonGroup.currentIndex = -1;
                bottomButtonGroup.currentIndex = -1;
            } else
            // النطاق الأوسط
            if (newIndex < root.bottomOffset) {
                topButtonGroup.currentIndex = -1;
                middleButtonGroup.currentIndex = newIndex - root.middleOffset;
                bottomButtonGroup.currentIndex = -1;
            } else
            // النطاق السفلي
            {
                topButtonGroup.currentIndex = -1;
                middleButtonGroup.currentIndex = -1;
                bottomButtonGroup.currentIndex = newIndex - root.bottomOffset;
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    // دالة مساعدة لتحديث الحالة
    function updateGlobalState(localIndex, offset, groupName) {
        if (localIndex !== -1) {
            // Reset other groups
            if (groupName !== "top") topButtonGroup.currentIndex = -1;
            if (groupName !== "middle") middleButtonGroup.currentIndex = -1;
            if (groupName !== "bottom") bottomButtonGroup.currentIndex = -1;

            const globalIndex = offset + localIndex;

            // 1. All Apps Logic (Index 0)
            if (groupName === "bottom" && localIndex === 0 && App.useBottomLauncher) {
                bottomButtonGroup.currentIndex = -1;
                EventBus.emit(Events.TOGGLE_BOTTOM_LAUNCHER);
                return;
            }

            // 2. [NEW] Power Button Logic (Index 1)
            if (groupName === "bottom" && localIndex === 1) {
                // Deselect visually
                bottomButtonGroup.currentIndex = -1;
                
                // Trigger the external PanelWindow
                EventBus.emit(Events.TOGGLE_POWER_MENU);
                
                // Stop the side panel from expanding
                return;
            }

            // 3. Normal Sidebar Navigation
            root.activeMenuIndex = globalIndex;

            if (!root.panelOpen) {
                root.panelOpen = true;
                closePanelTimer.stop();
            }
            LeftMenuStatus.changeIndex(globalIndex);
        } else {
            // إذا ألغينا التحديد، نتأكد أن المجموعات الأخرى أيضاً غير محددة قبل الإغلاق
            if (topButtonGroup.currentIndex === -1 && middleButtonGroup.currentIndex === -1 && bottomButtonGroup.currentIndex === -1) {
                root.panelOpen = false;
                root.activeMenuIndex = -1;
                LeftMenuStatus.changeIndex(-1);
            }
        }

        changeIsMenuOpen.start();
    }
    

    // ---------------------------------------------------------
    // 3. UI GROUPS (الواجهات)
    // ---------------------------------------------------------

    // --- Top Group (System) ---
    ButtonGroup {
        id: topButtonGroup
        theme: ThemeManager.selectedTheme
        implicitWidth: 30

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        useHand: true
        model: topModel

        // تأثير الظل (يمكنك تكراره أو وضعه في مكون منفصل)
        layer.enabled: true
        layer.effect: MultiEffect {
            source: topButtonGroup
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

        onCurrentIndexChanged: updateGlobalState(topButtonGroup.currentIndex, 0, "top")
    }

    // --- Middle Group (Productivity) ---
    ButtonGroup {
        id: middleButtonGroup
        theme: ThemeManager.selectedTheme
        implicitWidth: 30
        // visible: false

        // التموضع في المنتصف تماماً
        anchors.centerIn: parent
        // أو استخدم anchors.verticalCenter: parent.verticalCenter مع left

        // هام: يجب إعادة ضبط الـ anchors لضمان المحاذاة اليسرى مثل البقية
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        useHand: true
        model: middleModel

        layer.enabled: true
        layer.effect: MultiEffect {
            source: middleButtonGroup
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

        onCurrentIndexChanged: updateGlobalState(middleButtonGroup.currentIndex, root.middleOffset, "middle")
    }

    // --- Bottom Group (Apps) ---
    ButtonGroup {
        id: bottomButtonGroup
        theme: ThemeManager.selectedTheme
        implicitWidth: 30

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 20
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        useHand: true
        model: bottomModel

        layer.enabled: true
        layer.effect: MultiEffect {
            source: bottomButtonGroup
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

        onCurrentIndexChanged: updateGlobalState(bottomButtonGroup.currentIndex, root.bottomOffset, "bottom")
    }

    function closePanel() {
        if (closePanelTimer !== undefined) {
            closePanelTimer.start();
        } else {
            LeftMenuStatus.changeIndex(-1);
        }
    }

    Timer {
        id: closePanelTimer
        interval: 20
        repeat: false
        onTriggered: LeftMenuStatus.changeIndex(-1)
    }

    Timer {
        id: changeIsMenuOpen
        interval: 2
        repeat: false
        onTriggered: {
            root.margins.left = panelOpen && App.menuStyle === Consts.DOCKED_MOVING_BAR ? ThemeManager.selectedTheme.dimensions.menuWidth : 0;
        }
    }
}

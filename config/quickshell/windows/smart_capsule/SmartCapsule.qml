import Quickshell
import QtQuick
import "root:/themes"
import "root:/config"
import "root:/config/ConstValues.js" as C
import "root:/windows/smart_capsule/logic"
import "root:/windows/smart_capsule/ui"
import "root:/windows/smart_capsule/ui/components"

PanelWindow {
    id: dynamicIsland

    anchors {
        top: true
        left: true
        right: true
    }
    color: "transparent"

    implicitHeight: Math.max(400, islandRect.height + islandRect.anchors.topMargin + 20)

    exclusionMode: ExclusionMode.Ignore
    mask: Region {
        item: islandRect
    }

    property string stateMode: C.STATE_IDLE
    property string activeTab: "media"
    property var _coordinator: CapsuleCoordinator
    property var _coordinatorTester: CapsuleTester

    // Margins
    property int barFullHeight: ThemeManager.selectedTheme.dimensions.barHeight
    property int idleWidgetHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    property int centeredTopMargin: (barFullHeight - idleWidgetHeight) / 2
    property int droppedTopMargin: barFullHeight + 10

    function expand(tabName) {
        activeTab = tabName;
        expandedContainer.currentTab = tabName; // Force tab update
        stateMode = C.STATE_EXPANDED;
    }

    function collapse() {
        stateMode = C.STATE_IDLE;
        // عند الإغلاق، نطلب من الكرت الداخلي إغلاق طبقة الذكاء الاصطناعي أيضاً
        expandedContainer.showAiOverlay = false;
    }

    NibrasShellShortcut {
        id: toggleMediaIsland
        name: "toggleMediaIsland"

        onPressed: {
            if (activeTab === "media" && stateMode === C.STATE_EXPANDED) {
                collapse();
            } else {
                expand("media");
            }
        }
    }

    NibrasShellShortcut {
        id: toggleWeatherIsland
        name: "toggleWeatherIsland"
        onPressed: {
            if (activeTab === "weather" && stateMode === C.STATE_EXPANDED) {
                collapse();
            } else {
                expand("weather");
            }
        }
    }

    Rectangle {
        id: islandRect
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true

        // التعديل 2: الربط الديناميكي بالأبعاد الضمنية (Implicit) للكرت الداخلي
        width: stateMode === C.STATE_EXPANDED ? expandedContainer.implicitWidth : idleBar.requiredWidth
        height: stateMode === C.STATE_EXPANDED ? expandedContainer.implicitHeight : idleBar.requiredHeight

        // الخلفية
        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: CapsuleManager.bgColor1
                Behavior on color {
                    ColorAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            GradientStop {
                position: 1.0
                color: CapsuleManager.bgColor2
                Behavior on color {
                    ColorAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        // 1. Idle Bar
        IdleBar {
            id: idleBar
            anchors.fill: parent
            visible: stateMode === C.STATE_IDLE
            opacity: visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            onRequestExpand: mode => dynamicIsland.expand(mode)
        }

        // 2. Expanded Card
        ExpandedCard {
            id: expandedContainer
            anchors.centerIn: parent

            // التعديل 3: إزالة العرض الثابت (width: 410)
            // نترك الكرت يحدد عرضه بنفسه (400 أو 450)
            // width: 410  <-- محذوف

            visible: stateMode === C.STATE_EXPANDED
            opacity: visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }

            onCurrentTabChanged: if (visible)
                dynamicIsland.activeTab = currentTab
            onCloseRequested: dynamicIsland.collapse()
        }

        // --- Animations ---
        // تحسين الأنيميشن ليكون أكثر مرونة مع التغيرات الكبيرة في الحجم
        Behavior on width {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 0.6 // تقليل الارتداد قليلاً للنصوص الطويلة
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }

        // التحكم في الموقع (Top Margin)
        anchors.topMargin: stateMode === C.STATE_EXPANDED ? dynamicIsland.droppedTopMargin : dynamicIsland.centeredTopMargin

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuart
            }
        }

        // Radius Animation
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        Behavior on radius {
            NumberAnimation {
                duration: 400
            }
        }
    }
}

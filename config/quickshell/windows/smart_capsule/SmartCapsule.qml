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
    implicitHeight: 400
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
        // color: "transparent"
        clip: true

        // إذا كنا موسعين، العرض 400 ثابت. إذا كنا مغلقين، نتبع المحتوى.
        width: stateMode === C.STATE_EXPANDED ? 410 : idleBar.requiredWidth
        height: stateMode === C.STATE_EXPANDED ? 220 : idleBar.requiredHeight

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

            // عند الاختفاء، يتلاشى بسرعة
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
            width: 410

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
        Behavior on width {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        // التحكم في الموقع (Top Margin)
        // عند التوسيع ينزل للأسفل قليلاً
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

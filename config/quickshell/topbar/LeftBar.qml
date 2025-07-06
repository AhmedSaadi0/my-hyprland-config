// pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
// import QtQuick.Layouts
import QtQuick.Effects

import "../themes"
import "../components"
import "root:/utils"
import "root:/services"

PanelWindow {
    id: root

    // --- Properties ---
    property bool panelOpen: false
    property int activeMenuIndex: LeftMenuStatus.selectedIndex
    exclusiveZone: 45

    // --- 2. خاصية لتخزين مؤشر عنصر الإشعارات ---
    property int notificationMenuIndex: -1

    // --- 3. ربط الواجهة بخدمة الإشعارات ---
    // هذا الكود يراقب التغييرات في NotifManager ويحدّث الواجهة
    Connections {
        target: NotifManager // الهدف هو الـ Singleton الخاص بنا

        // هذه الدالة تُستدعى تلقائياً عندما تتغير قيمة NotifManager.notificationCount
        function onNotificationCountChanged() {
            // نتأكد من أننا وجدنا عنصر الإشعارات أولاً
            if (root.notificationMenuIndex !== -1) {
                // نقوم بتحديث خاصية notificationCount في الموديل بكفاءة عالية
                buttonGroup.model.set(root.notificationMenuIndex, {
                    "notificationCount": NotifManager.notificationCount
                });
            }
        }
    }

    // --- 4. إعداد القيمة الأولية عند بدء تشغيل الواجهة ---
    Component.onCompleted: {
        // نبحث عن عنصر "Notifications" في الموديل مرة واحدة فقط
        for (let i = 0; i < buttonGroup.model.count; i++) {
            if (buttonGroup.model.get(i).name === "Notifications") {
                // نخزن مؤشره (index) للوصول السريع لاحقاً
                root.notificationMenuIndex = i;

                // نقوم بتعيين القيمة الأولية للعداد عند بدء التشغيل
                // هذا مهم في حال كانت هناك إشعارات موجودة بالفعل
                buttonGroup.model.set(i, {
                    "notificationCount": NotifManager.notificationCount
                });

                break; // نوقف البحث بعد العثور عليه
            }
        }
    }

    implicitWidth: 60
    implicitHeight: screen.height - ThemeManager.selectedTheme.dimensions.barHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            buttonGroup.currentIndex = newIndex;
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    anchors {
        top: true
        left: true
        bottom: true
    }
    margins {
        top: -10
    }

    CorneredBox {
        id: containerBox
        anchors.fill: parent
        bottomRightVisible: false
        topRightVisible: false
        layer.enabled: true
        layer.effect: MultiEffect {
            source: containerBox
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }

        ButtonGroup {
            id: buttonGroup
            implicitWidth: 30
            implicitHeight: 300
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            model: ListModel {
                ListElement {
                    icon: "󰨝"
                    name: "Dashboard"
                }
                ListElement {
                    icon: "󰂞"
                    name: "Notifications"
                    // القيمة الأولية هنا ستُحدّث فوراً عند بدء التشغيل
                    notificationCount: 0
                }
                ListElement {
                    icon: "󰨹"
                    name: "Weather"
                }
                ListElement {
                    icon: ""
                    name: "Monitors"
                }
                ListElement {
                    icon: ""
                    name: "Network"
                }
            }

            onCurrentIndexChanged: function () {
                const newIndex = buttonGroup.currentIndex;
                root.activeMenuIndex = newIndex;
                if (newIndex === -1) {
                    root.panelOpen = false;
                } else {
                    if (!root.panelOpen) {
                        root.panelOpen = true;
                    }
                }
                LeftMenuStatus.changeIndex(newIndex);
            }
        }
    }
}

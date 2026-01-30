import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../themes"

Rectangle {
    id: workspaceRectangle

    // --- الخصائص الأصلية (لم يتم تغيير القيم) ---
    property int underlineHeight: 2
    property int itemWidth: 33
    property int fontSize: 18
    property var activeIcons: ["", "󰿣", "󰂔", "󰉋", "󱙋", "󰭹", "󱍙", "󰺵", "󱋡", "󰙨"]
    property var inActiveIcons: ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰻞", "󱍚", "󰺶", "󱋢", "󰤑"]

    // تحديد الآيدي (ID) الحالي
    property int focusedId: Hyprland.focusedWorkspace !== null ? Hyprland.focusedWorkspace.id : 0

    // المصفوفات
    readonly property var workspaceIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    readonly property var reversedWorkspaceIds: workspaceIds.slice()//.reverse()

    // --- تحسين الكود: حساب المؤشر رياضياً بدلاً من اللوب ---
    // بما أن المصفوفة معكوسة (10 -> 1)، فإن المعادلة هي: 10 - الآيدي
    property int activeIndex: {
        if (focusedId >= 1 && focusedId <= 10)
            return focusedId - 1;
        return -1; // في حالة عدم وجود مساحة عمل نشطة ضمن النطاق
    }

    height: parent.height
    width: rowLayout.implicitWidth
    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    color: ThemeManager.selectedTheme.colors.topbarBgColorV1

    anchors {
        rightMargin: 5
    }

    RowLayout {
        id: rowLayout
        anchors.top: parent.top
        spacing: 5

        Repeater {
            model: workspaceRectangle.reversedWorkspaceIds

            delegate: MouseArea {
                id: workspaceMouseArea
                width: workspaceRectangle.itemWidth
                height: workspaceRectangle.height

                readonly property int workspaceId: modelData
                readonly property bool isFocused: workspaceId === workspaceRectangle.focusedId
                readonly property bool exists: Hyprland.workspaces.values.some(ws => ws.id === workspaceId)

                readonly property color defaultItemColor: {
                    if (isFocused || exists) {
                        return ThemeManager.selectedTheme.colors.primary;
                    } else {
                        return palette.text.alpha(0.4);
                    }
                }

                readonly property string icon: isFocused ? workspaceRectangle.activeIcons[workspaceId - 1] ?? "" : workspaceRectangle.inActiveIcons[workspaceId - 1] ?? ""

                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch(`workspace ${workspaceMouseArea.workspaceId}`)

                Text {
                    id: iconText
                    anchors.centerIn: parent

                    text: workspaceMouseArea.icon
                    font.pixelSize: workspaceRectangle.fontSize
                    font.family: ThemeManager.selectedTheme.typography.iconFont

                    color: workspaceMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary : workspaceMouseArea.defaultItemColor

                    // أنيميشن اللون
                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    onTextChanged: {
                        if (exists) {
                            fadeTransition.restart();
                        }
                    }

                    SequentialAnimation {
                        id: fadeTransition
                        running: false
                        PropertyAnimation {
                            target: iconText
                            property: "opacity"
                            to: 0.5
                            duration: 150
                            easing.type: Easing.InQuad
                        }
                        PropertyAnimation {
                            target: iconText
                            property: "opacity"
                            to: 1
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: slidingIndicator

        //تحديد الموقع والحجم بناءً على الحساب الرياضي ---
        // الموقع = (رقم الترتيب * عرض العنصر) + (رقم الترتيب * المسافة الفاصلة)
        // نضيف 2 ونطرح 4 كما في الكود الأصلي للحفاظ على الهوامش الدقيقة
        property int targetX: (workspaceRectangle.activeIndex * workspaceRectangle.itemWidth) + (workspaceRectangle.activeIndex * 5)

        visible: workspaceRectangle.activeIndex !== -1

        x: visible ? targetX + 2 : -width // +2 من الكود الأصلي
        width: visible ? workspaceRectangle.itemWidth - 4 : 0 // -4 من الكود الأصلي

        height: workspaceRectangle.underlineHeight
        anchors.bottom: parent.bottom
        color: ThemeManager.selectedTheme.colors.primary
        radius: height / 2

        //  SpringAnimation ---
        // يجعل الحركة مرنة وناعمة بدلاً من الحركة الميكانيكية
        Behavior on x {
            SpringAnimation {
                spring: 3.0    // قوة النابض
                damping: 0.25  // تخفيف الاهتزاز
                mass: 1.0      // كتلة العنصر
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }
    }
}

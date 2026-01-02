// components/SettingSwitch.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string tooltip: ""

    // نستخدم alias لربط الخصائص مباشرة بالمكون الداخلي
    property alias isChecked: settingSwitch.checked
    property alias font: labelText.font

    // حساب الحجم تلقائياً
    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    ToolTip.text: root.tooltip
    ToolTip.visible: mouseArea.containsMouse && root.tooltip
    ToolTip.delay: 500

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: 10

        Label {
            id: labelText
            text: root.label
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            // جعل النص يأخذ لوناً باهتاً قليلاً إذا كان السويتش مغلقاً (لمسة جمالية اختيارية)
            opacity: root.enabled ? 1.0 : 0.5
        }

        Switch {
            id: settingSwitch
            Layout.alignment: Qt.AlignRight
            // السويتش في Qt Quick Controls 2 يتعامل مع النقرات تلقائياً
            // لذا لا نحتاج لمنطق معقد هنا
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        // نجعل الماوس يعمل فوق النص والمساحة الفارغة، لكن نسمح للنقرات بالوصول للسويتش
        // إذا ضغط المستخدم عليه مباشرة
        cursorShape: Qt.PointingHandCursor

        // الحل الصحيح للتفاعل:
        onClicked: {
            if (settingSwitch.enabled) {
                // نطلب من السويتش أن يغير حالته بنفسه
                // هذا يضمن تشغيل الأنيميشن والإشارات الصحيحة
                settingSwitch.toggle();
            }
        }
    }
}

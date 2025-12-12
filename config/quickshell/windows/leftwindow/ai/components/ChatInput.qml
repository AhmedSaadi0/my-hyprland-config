import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/components" // لاستدعاء مكوناتك العامة
import "root:/themes"

RowLayout {
    id: root
    spacing: 10

    signal sendClicked(string text)
    property bool isLoading: false

    // حقل النص
    SettingTextField {
        id: inputField
        Layout.fillWidth: true
        Layout.preferredHeight: 45
        placeholderText: "Ask Gemini..."

        // إرسال عند ضغط Enter (بدون Shift)
        Keys.onReturnPressed: event => {
            if (event.modifiers & Qt.ShiftModifier) {
                // سطر جديد
                event.accepted = false;
            } else {
                send();
            }
        }
    }

    // زر الإرسال
    MButton {
        Layout.preferredWidth: 45
        Layout.preferredHeight: 45

        text: root.isLoading ? "..." : "󰒭" // أيقونة إرسال
        enabled: !root.isLoading && inputField.text.trim().length > 0

        onClicked: send()
    }

    function send() {
        if (inputField.text.trim().length > 0) {
            root.sendClicked(inputField.text);
            inputField.text = ""; // تفريغ الحقل
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "root:/themes"

Rectangle {
    id: root

    // الخصائص التي سنمررها
    required property string messageText
    required property string role // "user" or "model"
    property bool isUser: role === "user"

    width: Math.min(parent.width * 0.85, messageLayout.implicitWidth + 30)
    height: messageLayout.implicitHeight + 20

    // المحاذاة: المستخدم يمين، المودل يسار
    anchors.right: isUser ? parent.right : undefined
    anchors.left: isUser ? undefined : parent.left

    radius: 12

    // الألوان حسب الثيم والمرسل
    color: isUser ? ThemeManager.selectedTheme.colors.accentColor : ThemeManager.selectedTheme.colors.surfaceColor

    opacity: 0.9

    ColumnLayout {
        id: messageLayout
        anchors.centerIn: parent
        width: parent.width - 24
        spacing: 4

        // اسم المرسل (اختياري)
        Text {
            text: root.isUser ? "You" : "Gemini"
            font.pixelSize: 10
            font.bold: true
            color: root.isUser ? Qt.darker(ThemeManager.selectedTheme.colors.textColor, 1.5) : ThemeManager.selectedTheme.colors.iconColor
            Layout.alignment: Qt.AlignLeft
        }

        // نص الرسالة
        Text {
            text: root.messageText
            color: root.isUser ? "#FFFFFF" // نص أبيض دائماً لرسائل المستخدم لتكون مقروءة على لون الـ Accent
             : ThemeManager.selectedTheme.colors.textColor

            font.pixelSize: 13
            wrapMode: Text.Wrap
            textFormat: Text.MarkdownText // هام جداً لتنسيق الأكواد

            Layout.fillWidth: true
        }
    }
}

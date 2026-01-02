// components/CustomLabel.qml
import QtQuick
import "root:/themes"

Text {
    id: root

    // --- الخصائص الافتراضية ---
    // هنا تضع الستايل الموحد لكل النصوص في تطبيقك
    font.pixelSize: 14
    color: ThemeManager.selectedTheme.colors.subtleTextColor
    wrapMode: Text.WordWrap // خاصية مهمة للنصوص الطويلة

    // --- الأسماء المستعارة (Aliases) ---
    // هذه تسمح لك بتغيير الخصائص من الخارج كما لو كنت تستخدم Text العادي
    property alias text: root.text
    property alias color: root.color
    property alias wrapMode: root.wrapMode
    property alias font: root.font
    property alias horizontalAlignment: root.horizontalAlignment
    property alias textFormat: root.textFormat
}

pragma Singleton
import QtQuick

QtObject {
    id: root

    // ============================================================
    // منحنى التسارع المستمر (Continuous Acceleration - Ease In)
    // ============================================================
    // يبدأ ببطء ويتسارع حتى اللحظة الأخيرة (يصطدم بـ 100% بأقصى سرعة)
    readonly property list<double> bezierAccelerate: [0.5, 0.0, 1.0, 1.0]

    // ============================================================
    // التوقيتات (Durations)
    // ============================================================
    readonly property int animDuration: 200
    readonly property int fadeDuration: 200
    readonly property int barExpandDuration: 200

    // ============================================================
    // إعدادات Hyprland (المصدر الوحيد)
    // ============================================================
    readonly property string hyprBezierAccelerate: "accelerate, 0.5, 0.0, 1.0, 1.0"

    readonly property string hyprAnimWindows: "1, 2.5, accelerate, slide right"
    readonly property string hyprAnimWindowsMove: "1, 2.5, accelerate, slide right"
    readonly property string hyprAnimWindowsOut: "1, 2.5, accelerate, slide left"
    readonly property string hyprAnimBorder: "1, 2, default"
    readonly property string hyprAnimBorderAngle: "1, 2, default"
    readonly property string hyprAnimFadeIn: "1, 2.5, accelerate"
    readonly property string hyprAnimFadeOut: "1, 2.5, accelerate"
    readonly property string hyprAnimWorkspaces: "1, 2.5, accelerate, slide fade"
}

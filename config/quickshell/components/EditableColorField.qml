// components/EditableColorField.qml

import QtQuick
import QtQuick.Controls

import "root:/themes"

// EditText that checks if input is a color and changes accordingly
TextField {
    id: root

    signal validColorUpdated(var newColor)

    topPadding: 0
    bottomPadding: 0

    property color normalBackground: "white"
    property color normalForeground: "black"
    property color errorBorderColor: "red"

    property int topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    property bool isValid: true

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    color: root.normalForeground

    onAccepted: {
        validateColor(root.text);
    }

    function validateColor(inputText) {
        var potentialColor = Qt.color(inputText);

        if (potentialColor.valid) {
            root.isValid = true;
            root.normalBackground = potentialColor;
            root.validColorUpdated(potentialColor);
        } else {
            root.isValid = false;
            console.info("خطأ: صيغة اللون '" + inputText + "' غير صحيحة. استخدم صيغة مثل #RRGGBB");
        }
    }

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        color: root.enabled ? root.normalBackground : root.normalBackground.alpha(0.4)

        border.color: root.isValid ? "transparent" : root.errorBorderColor
        border.width: root.isValid ? 0 : 1 // إظهار الحدود فقط عند وجود خطأ

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }
    }
}

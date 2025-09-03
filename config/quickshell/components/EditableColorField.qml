// components/EditableColorField.qml

import QtQuick

// EditText that checks if input is a color and changes accordingly
EditableField {
    id: root

    signal validColorUpdated(var newColor)
    borderColor: "transparent"
    borderSize: 0

    onAccepted: {
        validateColor(root.text);
    }

    topLeftRadius: selectedTheme.dimensions.baseRadius
    topRightRadius: selectedTheme.dimensions.baseRadius
    bottomLeftRadius: selectedTheme.dimensions.baseRadius
    bottomRightRadius: selectedTheme.dimensions.baseRadius

    function validateColor(inputText) {
        try {
            var potentialColor = Qt.color(inputText);

            if (potentialColor.valid) {
                root.normalBackground = potentialColor;
                root.validColorUpdated(potentialColor);
                root.borderColor = "transparent";
                root.borderSize = 0;
            } else {
                root.borderColor = "red";
                root.borderSize = 1;
                console.error("خطأ: صيغة اللون '" + inputText + "' غير صحيحة. استخدم صيغة مثل #RRGGBB");
            }
        } catch (ValidationException) {
            root.borderColor = "red";
            root.borderSize = 1;
            console.error("خطأ: صيغة اللون '" + inputText + "' غير صحيحة. استخدم صيغة مثل #RRGGBB");
        }
    }
}

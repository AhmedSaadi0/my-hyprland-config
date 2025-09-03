import QtQuick
import QtQuick.Dialogs

ColorDialog {
    property var targetField: null

    modality: Qt.ApplicationModal
    title: "اختر لونًا"

    // عند الفتح، قم بتعيين اللون الحالي لمربع الحوار
    onVisibleChanged: {
        if (visible && targetField) {
            // **التصحيح**: الخاصية هنا هي 'color'
            color = targetField.text;
        }
    }

    onAccepted: {
        if (targetField) {
            // **التصحيح**: الخاصية هنا هي 'selectedColor' عند الإغلاق
            targetField.text = selectedColor.toString();
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import "root:/themes"

RowLayout {
    id: root

    property alias label: titleLabel.text
    property double from: 0
    property double to: 100
    property double value: 0
    property double stepSize: 1
    property int decimals: 0

    signal currentValueChanged(double newValue)

    signal editingFinished(double finalValue)

    spacing: ThemeManager.selectedTheme.dimensions.spacingMedium

    Controls.Label {
        id: titleLabel
        font.bold: true
        Layout.fillWidth: true
    }

    Controls.Slider {
        id: slider
        Layout.preferredWidth: 200
        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.value
        live: true

        onValueChanged: {
            const roundedValue = Number(slider.value.toFixed(root.decimals));
            valueLabel.text = roundedValue;
            root.currentValueChanged(roundedValue);
        }

        onPressedChanged: {
            if (!pressed) {
                const finalRoundedValue = Number(slider.value.toFixed(root.decimals));
                root.editingFinished(finalRoundedValue);
            }
        }
    }

    Controls.Label {
        id: valueLabel
        text: Number(slider.value.toFixed(root.decimals))
        font.bold: true
        Layout.minimumWidth: 45
        horizontalAlignment: Text.AlignRight
    }

    onValueChanged: {
        if (slider.value !== root.value) {
            slider.value = root.value;
        }
    }
}

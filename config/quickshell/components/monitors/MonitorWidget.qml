// ../../../components/monitors/MonitorWidget.qml
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "../../themes"

ColumnLayout {
    id: monitorUnitRoot

    // Properties to be set by the parent (Progresses.qml)
    property string title: "Title"
    property string valueText: "100%" // This will be static or updated if your monitor component exposes its value

    // The component (e.g., Tempreture, Battery) to instantiate
    property var monitorComponent

    // Properties to pass down to the loaded monitorComponent
    property int monitorItemWidth: 70
    property int monitorItemHeight: 70
    // Add these if your TopbarCircularProgress (or Tempreture.qml) accepts them
    property int monitorItemThickness: 8
    property int monitorItemIconFontSize: 28

    // Alias to access the loaded monitor item if needed (e.g., to read its progress value)
    property alias actualMonitor: monitorLoader.item

    spacing: ThemeManager.selectedTheme.dimensions.smallSpacing || 4 // Spacing between title, value, and monitor

    Layout.alignment: Qt.AlignHCenter

    Text {
        id: titleLabel
        text: monitorUnitRoot.title
        font.bold: true
        font.pixelSize: ThemeManager.selectedTheme.typography.heading3Size
        color: Kirigami.Theme.textColor
        Layout.alignment: Qt.AlignHCenter // Center text horizontally
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width // Ensure text can use full width for centering
    }

    Text {
        id: valueLabel
        text: monitorUnitRoot.valueText
        font.pixelSize: ThemeManager.selectedTheme.typography.medium
        color: Kirigami.Theme.textColor
        Layout.alignment: Qt.AlignHCenter // Center text horizontally
        horizontalAlignment: Text.AlignHCenter
        width: parent.width // Ensure text can use full width for centering

        Component.onCompleted: {
            if (monitorLoader.item && "value" in monitorLoader.item) {
                function updateText() {
                    valueLabel.text = Math.round(monitorLoader.item.value * 100) + "%";
                }
                if (monitorLoader.item.valueChanged) {
                    monitorLoader.item.valueChanged.connect(updateText);
                }
                updateText(); // Initial update
            }
        }
    }

    Loader {
        id: monitorLoader
        sourceComponent: monitorUnitRoot.monitorComponent
        Layout.alignment: Qt.AlignHCenter // Center the loaded monitor

        // Pass properties to the loaded item (e.g., Tempreture.qml)
        // These properties must exist on the loaded components or their base (TopbarCircularProgress)
        onLoaded: {
            item.width = monitorUnitRoot.monitorItemWidth;
            item.height = monitorUnitRoot.monitorItemHeight + 2;

            // Safely set properties if they exist on the loaded item
            if ("thickness" in item) {
                item.thickness = monitorUnitRoot.monitorItemThickness;
            }
            if ("iconFontSize" in item) {
                item.iconFontSize = monitorUnitRoot.monitorItemIconFontSize;
            }
        }
    }
}

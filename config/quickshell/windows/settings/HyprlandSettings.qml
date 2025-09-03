import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Controls.ScrollView {
    clip: true
    Controls.Frame {
        padding: Kirigami.Units.largeSpacing
        GridLayout {
            columns: 2
            columnSpacing: Kirigami.Units.gridUnit
            rowSpacing: Kirigami.Units.gridUnit
            Controls.Label {
                text: "إعدادات Hyprland"
                font.bold: true
                Layout.columnSpan: 2
            }
            Controls.Label {
                text: "عرض الإطار:"
            }
            Controls.SpinBox {
                value: 2
                from: 0
                to: 10
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "لون الإطار النشط:"
            }
            Controls.TextField {
                text: "#bd93f9"
                Layout.fillWidth: true
            }
            Controls.Switch {
                text: "تفعيل الظل"
                checked: true
                Layout.columnSpan: 2
            }
        }
    }
}

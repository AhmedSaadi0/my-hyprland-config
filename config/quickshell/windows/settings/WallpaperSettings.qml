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
                text: "إعدادات النظام"
                font.bold: true
                Layout.columnSpan: 2
            }
            Controls.Label {
                text: "الخلفية الحالية:"
            }
            Controls.TextField {
                text: "/path/to/wallpaper.png"
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "وضع الثيم:"
            }
            Controls.ComboBox {
                model: ["Light", "Dark"]
                currentIndex: 1
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "الخلفيات المتحركة"
                font.bold: true
                Layout.columnSpan: 2
                Layout.topMargin: Kirigami.Units.largeSpacing
            }
            Controls.Switch {
                text: "تفعيل الألوان المتجاوبة"
                checked: true
                Layout.columnSpan: 2
            }
            Controls.Switch {
                text: "تفعيل الخلفيات المتحركة"
                checked: false
                Layout.columnSpan: 2
            }
        }
    }
}

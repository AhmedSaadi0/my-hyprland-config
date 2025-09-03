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
                text: "الإعدادات العامة"
                font.bold: true
                Layout.columnSpan: 2
            }
            Controls.Switch {
                text: "تفعيل ساعة سطح المكتب"
                checked: true
                Layout.columnSpan: 2
            }
            Controls.Label {
                text: "صيغة الوقت:"
            }
            Controls.TextField {
                text: "hh:mm:ss"
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "حجم الخط:"
            }
            Controls.SpinBox {
                value: 72
                from: 20
                to: 200
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "الألوان والظلال"
                font.bold: true
                Layout.columnSpan: 2
                Layout.topMargin: Kirigami.Units.largeSpacing
            }
            Controls.Label {
                text: "لون الخط:"
            }
            Controls.TextField {
                text: "#ffffff"
                Layout.fillWidth: true
            }
            Controls.Switch {
                text: "استخدام لون الثيم الأساسي"
                checked: false
                Layout.columnSpan: 2
            }
        }
    }
}

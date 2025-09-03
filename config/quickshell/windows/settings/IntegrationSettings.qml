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
                text: "KDE Plasma"
                font.bold: true
                Layout.columnSpan: 2
            }
            Controls.Label {
                text: "نمط البلازما:"
            }
            Controls.TextField {
                text: "BreezeDark"
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "بروفايل Konsole:"
            }
            Controls.TextField {
                text: "Profile 1"
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "GTK & Icons"
                font.bold: true
                Layout.columnSpan: 2
                Layout.topMargin: Kirigami.Units.largeSpacing
            }
            Controls.Label {
                text: "ثيم GTK:"
            }
            Controls.TextField {
                text: "Adwaita-dark"
                Layout.fillWidth: true
            }
            Controls.Label {
                text: "ثيم الأيقونات:"
            }
            Controls.TextField {
                text: "Papirus-Dark"
                Layout.fillWidth: true
            }
        }
    }
}

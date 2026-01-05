import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

Popup {
    id: datePopup
    width: 280
    height: 360
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property date selectedDate: new Date()
    property date viewDate: new Date()
    property var theme: ThemeManager.selectedTheme.colors
    property var typography: ThemeManager.selectedTheme.typography

    signal dateSelected(date date)

    background: Rectangle {
        color: "#1a1a1a"
        radius: 12
        border.color: Qt.rgba(theme.leftMenuFgColorV1.r, theme.leftMenuFgColorV1.g, theme.leftMenuFgColorV1.b, 0.2)
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "‹"
                flat: true
                onClicked: datePopup.viewDate = new Date(datePopup.viewDate.setMonth(datePopup.viewDate.getMonth() - 1))
                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter }
            }
            Text {
                Layout.fillWidth: true
                text: datePopup.viewDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                color: "white"; font.family: typography.bodyFont; font.bold: true; horizontalAlignment: Text.AlignHCenter
            }
            Button {
                text: "›"
                flat: true
                onClicked: datePopup.viewDate = new Date(datePopup.viewDate.setMonth(datePopup.viewDate.getMonth() + 1))
                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]
                delegate: Text {
                    Layout.fillWidth: true; text: modelData; color: theme.primary
                    font.pixelSize: 10; font.bold: true; horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        GridView {
            id: calendarGrid
            Layout.fillWidth: true; Layout.fillHeight: true
            cellWidth: width / 7; cellHeight: 40; interactive: false
            model: 42
            delegate: Item {
                width: calendarGrid.cellWidth; height: calendarGrid.cellHeight
                property var dayDate: {
                    let firstDay = new Date(datePopup.viewDate.getFullYear(), datePopup.viewDate.getMonth(), 1);
                    let startingOffset = firstDay.getDay();
                    let d = new Date(firstDay);
                    d.setDate(d.getDate() - startingOffset + index);
                    return d;
                }
                Rectangle {
                    anchors.fill: parent; anchors.margins: 4; radius: width / 2
                    color: dayDate.toDateString() === selectedDate.toDateString() ? theme.primary : "transparent"
                    Text {
                        anchors.centerIn: parent; text: dayDate.getDate()
                        color: dayDate.getMonth() === viewDate.getMonth() ? "white" : "#444"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            datePopup.dateSelected(dayDate)
                            datePopup.close()
                        }
                    }
                }
            }
        }
    }
}
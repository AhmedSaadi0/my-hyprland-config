import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/components"
import "root:/themes"

MenuCard {
    id: root

    title: "Themes"
    icon: ""
    // height: 300

    GridLayout {
        id: grid
        columns: 3

        columnSpacing: 10
        rowSpacing: 10

        MButton {
            text: "test"
            Layout.fillWidth: true
        }

        MButton {
            text: "test"
            Layout.fillWidth: true
        }
        MButton {
            text: "test"
            Layout.fillWidth: true
        }
    }
}

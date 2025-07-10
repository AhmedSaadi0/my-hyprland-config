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
            text: "Colors"
            iconText: ""
            Layout.fillWidth: true
            onClicked: ThemeManager.loadTheme("ColorsTheme")
            textLeftMargin: 2
            iconRightMargin: 2
            iconPreferredWidth: 1
        }

        MButton {
            text: "Deer"
            iconText: ""
            Layout.fillWidth: true
            onClicked: ThemeManager.loadTheme("DeerTheme")
            textLeftMargin: 2
            iconRightMargin: 2
            iconPreferredWidth: 1
        }

        MButton {
            text: "Base"
            iconText: "󰖔"
            Layout.fillWidth: true
            onClicked: ThemeManager.loadTheme("BaseTheme")
            textLeftMargin: 2
            iconRightMargin: 2
            iconPreferredWidth: 1
        }

        MButton {
            text: "Harmony"
            iconText: "󰔉"
            Layout.fillWidth: true
            onClicked: ThemeManager.loadTheme("HarmonyTheme")
            textLeftMargin: 2
            iconRightMargin: 2
            iconPreferredWidth: 1
        }

        MButton {
            text: "Dark"
            iconText: "󱀝"
            Layout.fillWidth: true
            onClicked: ThemeManager.loadTheme("DarkTheme")
            textLeftMargin: 2
            iconRightMargin: 2
            iconPreferredWidth: 1
        }

        MButton {
            text: "Base"
            iconText: ""
            Layout.fillWidth: true
            onClicked: ThemeManager.loadTheme("BaseTheme")
            textLeftMargin: 2
            iconRightMargin: 2
            iconPreferredWidth: 1
        }
    }
}

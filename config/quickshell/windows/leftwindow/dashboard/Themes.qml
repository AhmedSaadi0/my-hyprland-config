// windows/leftwindow/dashboard/Themes.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
// import QtQuick.Dialogs
// import Qt.labs.platform

import "../../../components"
import "../../../themes"
import "root:/config/EventNames.js" as Events
import "root:/config"

MenuCard {
    id: root

    title: qsTr("Themes & Customization")
    icon: ""

    property bool settingsExpanded: false

    readonly property int fixedHeight: (grid.implicitHeight + settingsHeader.height + fullThemesRow.implicitHeight + fullThemesRow2.implicitHeight - 35) * 2
    height: settingsExpanded ? settingsLayout.implicitHeight + padding + fixedHeight : fixedHeight

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    ColumnLayout {
        id: mainLayout
        spacing: 10

        RowLayout {
            id: fullThemesRow
            Layout.fillWidth: true
            spacing: 10 // مسافة بين البطاقات

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: qsTr("Dracula")
                lightThemeName: "DraculaLight"
                darkThemeName: "DraculaDark"
                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: qsTr("Catppuccin")
                lightThemeName: "CatppuccinLight"
                darkThemeName: "CatppuccinDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: qsTr("Material")
                lightThemeName: "M3Light"
                darkThemeName: "M3Dark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }
        }

        RowLayout {
            id: fullThemesRow2
            Layout.fillWidth: true
            spacing: 10 // مسافة بين البطاقات

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: qsTr("Nord")
                lightThemeName: "NordLight"
                darkThemeName: "NordDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: qsTr("Gruvbox")
                lightThemeName: "GruvboxLight"
                darkThemeName: "GruvboxDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }
            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: qsTr("Tokyo Night")
                lightThemeName: "TokyoNightLight"
                darkThemeName: "TokyoNightDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }
        }

        Label {
            id: singleThemeLabel
            text: qsTr("Single Themes")
            font.pointSize: 10
            font.bold: true
            color: Kirigami.Theme.textColor
            opacity: 0.8
            Layout.topMargin: 5
            // Layout.horizontalCenter: parent.horizontalCenter

        }

        GridLayout {
            id: grid
            columns: 3
            Layout.fillWidth: true
            columnSpacing: 10
            rowSpacing: 10

            MButton {
                text: qsTr("Colors")
                onClicked: {
                    ThemeManager.requestLoadTheme("ColorsTheme");
                    closeMenu.start();
                }
                Layout.fillWidth: true
                iconText: ""
                isActive: ThemeManager.selectedTheme.themeName === "ColorsTheme"
            }
            MButton {
                text: qsTr("Deer")
                onClicked: {
                    ThemeManager.requestLoadTheme("DeerTheme");
                    closeMenu.start();
                }
                Layout.fillWidth: true
                iconText: ""
                isActive: ThemeManager.selectedTheme.themeName === "DeerTheme"
            }
        }

        Rectangle {
            id: sperator
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            height: 1
            color: ThemeManager.selectedTheme.colors.topbarFgColorV1.alpha(0.2)
        }

        Rectangle {
            id: settingsHeader
            Layout.fillWidth: true
            height: 30
            color: "transparent"
            radius: 4

            // خاصية إضافية للتحكم في الـ scale
            property real pressScale: 1.0
            scale: pressScale

            Behavior on pressScale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.InOutQuad
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Label {
                    text: "Advanced Customization"
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }
                Item {
                    Layout.fillWidth: true
                }
                Label {
                    id: expandIcon
                    text: ""
                    font.family: "FantasqueSansM Nerd Font Propo"
                    font.pixelSize: 16
                    color: Kirigami.Theme.textColor
                    rotation: root.settingsExpanded ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: settingsHeader.pressScale = 0.95
                onReleased: settingsHeader.pressScale = 1.0
                onClicked: {
                    EventBus.emit(Events.OPEN_SETTINGS);
                    EventBus.emit(Events.CLOSE_LEFTBAR);
                }
            }
        }
    }

    Timer {
        id: closeMenu
        interval: 600
        repeat: false
        onTriggered: {
            EventBus.emit(Events.CLOSE_LEFTBAR);
        }
    }
}

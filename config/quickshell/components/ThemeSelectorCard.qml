// components/ThemeSelectorCard.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"

Rectangle {
    id: card

    property string themeTitle: "Theme"
    property string lightThemeName: ""
    property string darkThemeName: ""

    property bool isSelected: false

    width: parent.width
    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    color: ThemeManager.selectedTheme.colors.topbarBgColorV2.alpha(0.7)
    height: columnLayout.implicitHeight + 20

    border.width: isSelected ? 2 : 0
    border.color: isSelected ? ThemeManager.selectedTheme.colors.primary : "transparent"

    Behavior on border.width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: card.themeTitle
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            Layout.bottomMargin: 4
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            MButton {
                text: ""
                // iconText: "" // أيقونة الوضع الفاتح
                Layout.fillWidth: true
                topRightRadius: 0
                bottomRightRadius: 0
                isActive: ThemeManager.selectedTheme.themeName === card.lightThemeName
                onClicked: {
                    ThemeManager.requestLoadTheme(card.lightThemeName);
                    closeMenu.start();
                    // EventBus.emit(Events.CLOSE_LEFTBAR);
                }
            }

            MButton {
                text: "󰖔"
                Layout.fillWidth: true
                topLeftRadius: 0
                bottomLeftRadius: 0
                isActive: ThemeManager.selectedTheme.themeName === card.darkThemeName
                onClicked: {
                    ThemeManager.requestLoadTheme(card.darkThemeName);
                    closeMenu.start();
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

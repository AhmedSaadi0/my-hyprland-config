// windows/bottomlauncher/CategoryFilter.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "root:/components"

Item {
    id: root
    
    property string selectedCategory: ""

    // Simplified category definitions
    readonly property var categories: [
        { label: "All", category: "" },
        { label: "Dev", category: "Development" },
        { label: "Games", category: "Game" },
        { label: "Graphics", category: "Graphics" },
        { label: "Internet", category: "Network" },
        { label: "Media", category: "AudioVideo" },
        { label: "Office", category: "Office" },
        { label: "System", category: "System" },
        { label: "Utils", category: "Utility" }
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 6

        Repeater {
            model: root.categories

            Rectangle {
                id: categoryBtn
                Layout.preferredHeight: 28
                Layout.preferredWidth: categoryText.implicitWidth + 20
                radius: ThemeManager.selectedTheme.dimensions.elementRadius

                property bool isSelected: root.selectedCategory === modelData.category

                color: isSelected 
                    ? ThemeManager.selectedTheme.colors.primary
                    : mouseArea.containsMouse 
                        ? ThemeManager.selectedTheme.colors.leftMenuBgColorV2
                        : "transparent"

                border.color: isSelected 
                    ? ThemeManager.selectedTheme.colors.primary
                    : ThemeManager.selectedTheme.colors.primary.alpha(0.3)
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                }

                Text {
                    id: categoryText
                    anchors.centerIn: parent
                    text: modelData.label
                    font.pixelSize: 12
                    font.weight: categoryBtn.isSelected ? Font.DemiBold : Font.Normal
                    color: categoryBtn.isSelected 
                        ? ThemeManager.selectedTheme.colors.onPrimary
                        : ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.selectedCategory = modelData.category;
                    }
                }
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }
    }
}

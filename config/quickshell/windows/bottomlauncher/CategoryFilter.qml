// windows/bottomlauncher/CategoryFilter.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "root:/components"
import "root:/components/tab"

Item {
    id: root

    property string selectedCategory: ""

    readonly property var categories: [
        {
            label: "All",
            category: "",
            icon: "",
            width: 75
        },
        {
            label: "Dev",
            category: "Development",
            icon: "",
            width: 85
        },
        {
            label: "Games",
            category: "Game",
            icon: "󰸿",
            width: 100
        },
        {
            label: "Graphics",
            category: "Graphics",
            icon: "󰽉",
            width: 110
        },
        {
            label: "Internet",
            category: "Network",
            icon: "󰖟",
            width: 105
        },
        {
            label: "Media",
            category: "AudioVideo",
            icon: "",
            width: 90
        },
        {
            label: "Office",
            category: "Office",
            icon: "",
            width: 90
        },
        {
            label: "System",
            category: "System",
            icon: "",
            width: 95
        },
        {
            label: "Utils",
            category: "Utility",
            icon: "",
            width: 85
        }
    ]

    TabBar {
        id: filterBar
        anchors.fill: parent

        vertical: false
        barLength: parent.width
        barThickness: 32

        color: "transparent"
        ensureVisibility: true

        highlightColor: ThemeManager.selectedTheme.colors.primary
        textHighlightColor: ThemeManager.selectedTheme.colors.onPrimary
        textColor: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
        hoverColor: ThemeManager.selectedTheme.colors.leftMenuBgColorV2

        model: root.categories.map(item => ({
                    text: item.label,
                    icon: item.icon,
                    expandedWidth: item.width || 100,
                    closedWidth: 40,
                    onClick: function () {
                        root.selectedCategory = item.category;
                    }
                }))

        Connections {
            target: root
            function onSelectedCategoryChanged() {
                if (root.selectedCategory === "") {
                    filterBar.currentIndex = 0;
                }
            }
        }
    }
}

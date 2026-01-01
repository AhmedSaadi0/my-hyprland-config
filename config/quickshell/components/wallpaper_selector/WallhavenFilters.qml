// components/wallpaper_selector/WallhavenFilters.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"

Flow {
    id: root

    property string sorting: "toplist"
    property string order: "desc"
    property string topRange: "1M"
    property string category: "110"
    property string color: ""
    property string resolution: ""

    // Internal preset data
    readonly property var topRangePresets: [
        { name: "Day", value: "1d" },
        { name: "3 Days", value: "3d" },
        { name: "Week", value: "1w" },
        { name: "Month", value: "1M" },
        { name: "3 Months", value: "3M" },
        { name: "6 Months", value: "6M" },
        { name: "1 Year", value: "1y" }
    ]

    readonly property var colorPresets: [
        { name: "Any", hex: "" },
        { name: "Lonestar", hex: "660000" },
        { name: "Red Berry", hex: "990000" },
        { name: "Guardsman Red", hex: "cc0000" },
        { name: "Persian Red", hex: "cc3333" },
        { name: "French Rose", hex: "ea4c88" },
        { name: "Plum", hex: "993399" },
        { name: "Royal Purple", hex: "663399" },
        { name: "Sapphire", hex: "333399" },
        { name: "Science Blue", hex: "0066cc" },
        { name: "Pacific Blue", hex: "0099cc" },
        { name: "Downy", hex: "66cccc" },
        { name: "Atlantis", hex: "77cc33" },
        { name: "Limeade", hex: "669900" },
        { name: "Verdun Green", hex: "336600" },
        { name: "Verdun Green 2", hex: "666600" },
        { name: "Olive", hex: "999900" },
        { name: "Earls Green", hex: "cccc33" },
        { name: "Yellow", hex: "ffff00" },
        { name: "Sunglow", hex: "ffcc33" },
        { name: "Orange Peel", hex: "ff9900" },
        { name: "Blaze Orange", hex: "ff6600" },
        { name: "Tuscany", hex: "cc6633" },
        { name: "Potters Clay", hex: "996633" },
        { name: "Nutmeg", hex: "663300" },
        { name: "Black", hex: "000000" },
        { name: "Dusty Gray", hex: "999999" },
        { name: "Silver", hex: "cccccc" },
        { name: "White", hex: "ffffff" },
        { name: "Gun Powder", hex: "424153" }
    ]

    readonly property var resolutionPresets: [
        { name: "Any", value: "" },
        { name: "HD", value: "1280x720" },
        { name: "FHD", value: "1920x1080" },
        { name: "2K", value: "2560x1440" },
        { name: "4K", value: "3840x2160" },
        { name: "5K", value: "5120x2880" },
        { name: "8K", value: "7680x4320" },
        { name: "UW FHD", value: "2560x1080" },
        { name: "UW QHD", value: "3440x1440" }
    ]

    signal sortingSelected(string value)
    signal orderSelected(string value)
    signal topRangeSelected(string value)
    signal categorySelected(string value)
    signal colorSelected(string value)
    signal resolutionSelected(string value)

    spacing: 6

    // Sorting dropdown with order and topRange
    Rectangle {
        id: sortingBtn
        width: sortingText.width + 16
        height: 28
        radius: 6
        color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"

        Text {
            id: sortingText
            anchors.centerIn: parent
            text: {
                const sorts = { "toplist": "Top", "date_added": "New", "random": "Random", "views": "Views", "relevance": "Relevant", "favorites": "Fav" };
                let label = sorts[root.sorting] || "Top";
                if (root.sorting === "toplist") {
                    const range = root.topRangePresets.find(r => r.value === root.topRange);
                    label += " (" + (range ? range.name : root.topRange) + ")";
                }
                label += root.order === "asc" ? " ↑" : " ↓";
                return label;
            }
            font.pixelSize: 11
            color: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: sortingPopup.visible ? sortingPopup.close() : sortingPopup.open()
        }

        Popup {
            id: sortingPopup
            x: 0
            y: -height - 4
            width: 180
            padding: 8
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#1a1a2e"
                radius: 8
                border.color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#444"
                border.width: 1
            }

            contentItem: Column {
                spacing: 6

                Grid {
                    columns: 3
                    spacing: 4

                    Repeater {
                        model: [
                            { name: "Top", value: "toplist" },
                            { name: "New", value: "date_added" },
                            { name: "Random", value: "random" },
                            { name: "Views", value: "views" },
                            { name: "Fav", value: "favorites" },
                            { name: "Relevant", value: "relevance" }
                        ]

                        Rectangle {
                            id: sortOptionRect
                            required property var modelData
                            width: 52
                            height: 26
                            radius: 4
                            color: root.sorting === sortOptionRect.modelData.value
                                ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                            border.color: root.sorting === sortOptionRect.modelData.value
                                ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: sortOptionRect.modelData.name
                                font.pixelSize: 10
                                color: root.sorting === sortOptionRect.modelData.value
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.sortingSelected(sortOptionRect.modelData.value)
                            }
                        }
                    }
                }

                Row {
                    spacing: 4

                    Repeater {
                        model: [
                            { name: "Desc ↓", value: "desc" },
                            { name: "Asc ↑", value: "asc" }
                        ]

                        Rectangle {
                            id: orderRect
                            required property var modelData
                            width: 80
                            height: 26
                            radius: 4
                            color: root.order === orderRect.modelData.value
                                ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                            border.color: root.order === orderRect.modelData.value
                                ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: orderRect.modelData.name
                                font.pixelSize: 10
                                color: root.order === orderRect.modelData.value
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.orderSelected(orderRect.modelData.value)
                            }
                        }
                    }
                }

                Column {
                    spacing: 4
                    visible: root.sorting === "toplist"

                    Rectangle {
                        width: 164
                        height: 1
                        color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                    }

                    Text {
                        text: "Time Range"
                        font.pixelSize: 9
                        color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                    }

                    Grid {
                        columns: 2
                        spacing: 4

                        Repeater {
                            model: root.topRangePresets

                            Rectangle {
                                id: rangeRect
                                required property var modelData
                                width: 78
                                height: 24
                                radius: 4
                                color: root.topRange === rangeRect.modelData.value
                                    ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                    : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                                border.color: root.topRange === rangeRect.modelData.value
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : "transparent"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: rangeRect.modelData.name
                                    font.pixelSize: 10
                                    color: root.topRange === rangeRect.modelData.value
                                        ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                        : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.topRangeSelected(rangeRect.modelData.value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Categories dropdown
    Rectangle {
        id: categoriesBtn
        width: catBtnText.width + 16
        height: 28
        radius: 6
        color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"

        Text {
            id: catBtnText
            anchors.centerIn: parent
            text: "Categories"
            font.pixelSize: 11
            color: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: categoriesPopup.visible ? categoriesPopup.close() : categoriesPopup.open()
        }

        Popup {
            id: categoriesPopup
            x: 0
            y: -height - 4
            padding: 8
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#1a1a2e"
                radius: 8
                border.color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#444"
                border.width: 1
            }

            contentItem: Column {
                spacing: 4

                Repeater {
                    model: [
                        { label: "General", mask: 0 },
                        { label: "Anime", mask: 1 },
                        { label: "People", mask: 2 }
                    ]

                    Rectangle {
                        id: catPopupRect
                        required property var modelData
                        property bool isOn: root.category.charAt(catPopupRect.modelData.mask) === "1"
                        
                        width: 100
                        height: 28
                        radius: 4
                        color: catPopupRect.isOn
                            ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                            : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                        border.color: catPopupRect.isOn
                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                            : "transparent"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 14
                                height: 14
                                radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: catPopupRect.isOn 
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : "transparent"
                                border.color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: catPopupRect.isOn ? "✓" : ""
                                    font.pixelSize: 10
                                    color: "#fff"
                                }
                            }

                            Text {
                                text: catPopupRect.modelData.label
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                                color: catPopupRect.isOn
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let cats = root.category.split("");
                                cats[catPopupRect.modelData.mask] = cats[catPopupRect.modelData.mask] === "1" ? "0" : "1";
                                if (cats.join("") !== "000") {
                                    root.categorySelected(cats.join(""));
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Color filter
    Rectangle {
        id: colorFilterBtn
        height: 28
        width: colorFilterRow.width + 12
        radius: 6
        color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
        border.color: root.color !== "" ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : "transparent"
        border.width: 1

        Row {
            id: colorFilterRow
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
                width: 14
                height: 14
                radius: 7
                anchors.verticalCenter: parent.verticalCenter
                color: root.color !== "" ? ("#" + root.color) : "transparent"
                border.color: root.color === "" 
                    ? ThemeManager.selectedTheme?.colors?.subtleText || "#666" 
                    : "transparent"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.color === "" ? "?" : ""
                    font.pixelSize: 9
                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                }
            }

            Text {
                text: root.color === "" ? "Color" : root.colorPresets.find(c => c.hex === root.color)?.name || "Custom"
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
                color: root.color !== ""
                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                    : ThemeManager.selectedTheme?.colors?.subtleText || "#888"
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: colorPopup.open()
        }

        Popup {
            id: colorPopup
            x: 0
            y: parent.height + 4
            width: 220
            padding: 8

            background: Rectangle {
                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#1a1a2e"
                radius: 8
                border.color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#444"
                border.width: 1
            }

            contentItem: Grid {
                columns: 6
                spacing: 4

                Repeater {
                    model: root.colorPresets

                    Rectangle {
                        id: colorPresetRect
                        required property var modelData
                        required property int index

                        width: 32
                        height: 24
                        radius: 4
                        color: colorPresetRect.modelData.hex === "" 
                            ? ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#333"
                            : ("#" + colorPresetRect.modelData.hex)
                        border.color: root.color === colorPresetRect.modelData.hex
                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                            : (colorPresetRect.modelData.hex === "ffffff" || colorPresetRect.modelData.hex === "cccccc" ? "#999" : "transparent")
                        border.width: root.color === colorPresetRect.modelData.hex ? 2 : 1

                        Text {
                            anchors.centerIn: parent
                            text: colorPresetRect.modelData.hex === "" ? "✕" : ""
                            font.pixelSize: 12
                            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                        }

                        ToolTip.visible: colorPresetMouse.containsMouse
                        ToolTip.text: colorPresetRect.modelData.name
                        ToolTip.delay: 500

                        MouseArea {
                            id: colorPresetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.colorSelected(colorPresetRect.modelData.hex);
                                colorPopup.close();
                            }
                        }
                    }
                }
            }
        }
    }

    // Resolution filter
    Rectangle {
        id: resFilterBtn
        height: 28
        width: resFilterText.width + 12
        radius: 6
        color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
        border.color: root.resolution !== "" ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : "transparent"
        border.width: 1

        Text {
            id: resFilterText
            anchors.centerIn: parent
            text: root.resolution === "" ? "Resolution" : root.resolutionPresets.find(r => r.value === root.resolution)?.name || root.resolution
            font.pixelSize: 11
            color: root.resolution !== ""
                ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                : ThemeManager.selectedTheme?.colors?.subtleText || "#888"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: resPopup.open()
        }

        Popup {
            id: resPopup
            x: 0
            y: parent.height + 4
            width: 120
            padding: 8

            background: Rectangle {
                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#1a1a2e"
                radius: 8
                border.color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#444"
                border.width: 1
            }

            contentItem: Column {
                spacing: 4

                Repeater {
                    model: root.resolutionPresets

                    Rectangle {
                        id: resPresetRect
                        required property var modelData
                        required property int index

                        width: 104
                        height: 28
                        radius: 6
                        color: root.resolution === resPresetRect.modelData.value
                            ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                            : resPresetMouse.containsMouse
                                ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.1) || "#222"
                                : "transparent"
                        border.color: root.resolution === resPresetRect.modelData.value
                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                            : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: resPresetRect.modelData.name + (resPresetRect.modelData.value !== "" ? "+" : "")
                            font.pixelSize: 11
                            color: root.resolution === resPresetRect.modelData.value
                                ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                        }

                        MouseArea {
                            id: resPresetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.resolutionSelected(resPresetRect.modelData.value);
                                resPopup.close();
                            }
                        }
                    }
                }
            }
        }
    }
}

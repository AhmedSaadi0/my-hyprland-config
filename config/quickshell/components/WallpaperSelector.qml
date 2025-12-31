// components/WallpaperSelector.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt.labs.platform

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/utils"

Item {
    id: root

    signal wallpaperSelected(string path)
    signal closeRequested

    // Catch clicks on blank areas to prevent closing the launcher
    MouseArea {
        anchors.fill: parent
        onClicked: event => event.accepted = true
    }

    property bool compact: width < 400 // For sidebar use
    property bool applyToAllMonitors: true
    property string filterText: ""
    property int sourceMode: 0 // 0 = Local, 1 = Custom, 2 = Wallhaven

    property var localWallpapers: []
    property var customWallpapers: []
    property var wallhavenWallpapers: []
    property string customFolderPath: ThemeManager.selectedTheme?.systemSettings?.dynamicWallpapersPath || ""

    // Wallhaven settings
    property string wallhavenQuery: ""
    property string wallhavenCategory: "110" // General + Anime (no People)
    property string wallhavenPurity: "100"   // sfw only
    property string wallhavenSorting: "toplist"
    property string wallhavenOrder: "desc" // desc or asc
    property string wallhavenTopRange: "1M"
    property string wallhavenColor: "" // Color filter (hex without #)
    property int wallhavenPage: 1
    property bool wallhavenLoading: false
    property bool wallhavenHasMore: true

    // Top range presets
    property var topRangePresets: [
        { name: "Day", value: "1d" },
        { name: "3 Days", value: "3d" },
        { name: "Week", value: "1w" },
        { name: "Month", value: "1M" },
        { name: "3 Months", value: "3M" },
        { name: "6 Months", value: "6M" },
        { name: "1 Year", value: "1y" }
    ]

    // Wallhaven color palette
    property var colorPresets: [
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

    // Resolution filter
    property string wallhavenResolution: "" // atleast resolution (e.g. "1920x1080")
    property var resolutionPresets: [
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

    property var sourceNames: ["Local", "Custom", "Wallhaven"]

    property var currentWallpapers: {
        if (sourceMode === 0) return localWallpapers;
        if (sourceMode === 1) return customWallpapers;
        return wallhavenWallpapers;
    }

    property var filteredWallpapers: {
        if (sourceMode === 2) return currentWallpapers; // Wallhaven uses API search
        if (!currentWallpapers || currentWallpapers.length === 0) return [];
        if (filterText === "") return currentWallpapers;

        const searchLower = filterText.toLowerCase();
        return currentWallpapers.filter(path => {
            const filename = (typeof path === 'string' ? path : path.path || "").split('/').pop().toLowerCase();
            return filename.includes(searchLower);
        });
    }

    Component.onCompleted: {
        loadLocalWallpapers();
        if (customFolderPath !== "") {
            loadCustomWallpapers();
        }
    }

    function loadLocalWallpapers() {
        localWallpapersProcess.command = Helper.getWallpapersList(App.wallpapersPath);
        localWallpapersProcess.running = true;
    }

    function loadCustomWallpapers() {
        if (customFolderPath === "") return;
        customWallpapersProcess.command = Helper.getWallpapersList(customFolderPath);
        customWallpapersProcess.running = true;
    }

    function searchWallhaven(resetPage) {
        if (wallhavenLoading) return;
        
        if (resetPage) {
            wallhavenPage = 1;
            wallhavenWallpapers = [];
            wallhavenHasMore = true;
        }

        wallhavenLoading = true;
        
        let url = "https://wallhaven.cc/api/v1/search?";
        url += "categories=" + wallhavenCategory;
        url += "&purity=" + wallhavenPurity;
        url += "&sorting=" + wallhavenSorting;
        url += "&order=" + wallhavenOrder;
        
        if (wallhavenSorting === "toplist") {
            url += "&topRange=" + wallhavenTopRange;
        }
        
        if (wallhavenQuery !== "") {
            url += "&q=" + encodeURIComponent(wallhavenQuery);
        }

        if (wallhavenColor !== "") {
            url += "&colors=" + wallhavenColor;
        }

        if (wallhavenResolution !== "") {
            url += "&atleast=" + wallhavenResolution;
        }
        
        url += "&page=" + wallhavenPage;

        wallhavenProcess.command = ["curl", "-s", url];
        wallhavenProcess.running = true;
    }

    function loadMoreWallhaven() {
        if (wallhavenLoading || !wallhavenHasMore) return;
        wallhavenPage++;
        searchWallhaven(false);
    }

    function selectWallpaper(wallpaperData) {
        let path = "";
        
        if (sourceMode === 2) {
            // Wallhaven - need to download first
            if (typeof wallpaperData === 'object') {
                path = wallpaperData.path;
                // Download to cache folder
                downloadWallhaven(wallpaperData);
                return;
            }
        } else {
            path = typeof wallpaperData === 'string' ? wallpaperData : wallpaperData.path;
        }

        applyWallpaper(path);
    }

    function downloadWallhaven(wallpaperData) {
        const filename = wallpaperData.id + "." + wallpaperData.file_type.split('/')[1];
        const cachePath = App.cacheFolderPath + "/wallpapers";
        const filePath = cachePath + "/" + filename;

        // Create cache dir and download
        wallhavenDownloadProcess.wallpaperPath = filePath;
        wallhavenDownloadProcess.command = [
            "sh", "-c",
            "mkdir -p '" + cachePath + "' && curl -s -L -o '" + filePath + "' '" + wallpaperData.path + "'"
        ];
        wallhavenDownloadProcess.running = true;
    }

    function applyWallpaper(path) {
        ThemeManager.updateAndApplyTheme({
            "_wallpaper": path,
            "_enableDynamicWallpapers": false
        }, true);
        root.wallpaperSelected(path);
    }

    Process {
        id: localWallpapersProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(this.text);
                    root.localWallpapers = list || [];
                } catch (e) {
                    console.error("WallpaperSelector: Failed to parse local wallpapers", e);
                    root.localWallpapers = [];
                }
            }
        }
    }

    Process {
        id: customWallpapersProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(this.text);
                    root.customWallpapers = list || [];
                } catch (e) {
                    console.error("WallpaperSelector: Failed to parse custom wallpapers", e);
                    root.customWallpapers = [];
                }
            }
        }
    }

    Process {
        id: wallhavenProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallhavenLoading = false;
                try {
                    const response = JSON.parse(this.text);
                    if (response.data && Array.isArray(response.data)) {
                        const newWallpapers = response.data.map(w => ({
                            id: w.id,
                            path: w.path,
                            thumb: w.thumbs.large,
                            resolution: w.resolution,
                            file_type: w.file_type,
                            views: w.views,
                            favorites: w.favorites
                        }));
                        
                        if (root.wallhavenPage === 1) {
                            root.wallhavenWallpapers = newWallpapers;
                        } else {
                            root.wallhavenWallpapers = root.wallhavenWallpapers.concat(newWallpapers);
                        }

                        // Check if there are more pages
                        if (response.meta) {
                            root.wallhavenHasMore = response.meta.current_page < response.meta.last_page;
                        }
                    }
                } catch (e) {
                    console.error("WallpaperSelector: Failed to parse Wallhaven response", e);
                }
            }
        }
    }

    Process {
        id: wallhavenDownloadProcess
        property string wallpaperPath: ""
        
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && wallpaperPath !== "") {
                root.applyWallpaper(wallpaperPath);
            } else {
                console.error("WallpaperSelector: Download failed with exit code", exitCode);
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Select Wallpapers Folder"
        onAccepted: {
            var path = folder.toString().replace("file://", "");
            root.customFolderPath = path;
            root.loadCustomWallpapers();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "󰸉"
                font.pixelSize: 24
                font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                color: ThemeManager.selectedTheme?.colors?.primary || "#fff"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: qsTr("Wallpaper Selector")
                    font.pixelSize: 16
                    font.bold: true
                    color: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                }

                Text {
                    text: sourceMode === 2 ? qsTr("Browse wallpapers from Wallhaven.cc") : qsTr("Select a wallpaper to apply")
                    font.pixelSize: 11
                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                }
            }

            // Settings button (for custom folder)
            Rectangle {
                width: 28
                height: 28
                radius: 6
                visible: root.sourceMode === 1
                color: settingsMouseArea.containsMouse 
                    ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰉋"
                    font.pixelSize: 16
                    font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                }

                MouseArea {
                    id: settingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: folderDialog.open()
                }
            }

            // Refresh button
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: refreshMouseArea.containsMouse 
                    ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.wallhavenLoading ? "󰦖" : "󰑐"
                    font.pixelSize: 16
                    font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"

                    RotationAnimation on rotation {
                        running: root.wallhavenLoading
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.sourceMode === 0) {
                            root.loadLocalWallpapers();
                        } else if (root.sourceMode === 1) {
                            root.loadCustomWallpapers();
                        } else {
                            root.searchWallhaven(true);
                        }
                    }
                }
            }

            // Close button
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: closeMouseArea.containsMouse 
                    ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.pixelSize: 16
                    font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }
        }

        // Source tabs
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: root.sourceNames

                Rectangle {
                    id: tabRect
                    required property int index
                    required property string modelData
                    
                    Layout.fillWidth: true
                    height: 32
                    radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
                    color: root.sourceMode === tabRect.index
                        ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                        : tabMouseArea.containsMouse
                            ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.1) || "#222"
                            : "transparent"
                    border.color: root.sourceMode === tabRect.index
                        ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                        : "transparent"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: tabRect.modelData
                        font.pixelSize: 12
                        font.weight: root.sourceMode === tabRect.index ? Font.Bold : Font.Normal
                        color: root.sourceMode === tabRect.index
                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                            : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                    }

                    MouseArea {
                        id: tabMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.sourceMode = tabRect.index;
                            if (tabRect.index === 2 && root.wallhavenWallpapers.length === 0) {
                                root.searchWallhaven(true);
                            }
                        }
                    }
                }
            }
        }

        // Search bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            EditableField {
                id: searchField
                Layout.fillWidth: true
                Layout.preferredHeight: 36

                placeholderText: root.sourceMode === 2 
                    ? qsTr("Search Wallhaven (e.g. nature, anime, abstract)...")
                    : qsTr("Filter wallpapers...")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignLeft

                normalBackground: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                normalForeground: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                focusedBorderColor: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                borderColor: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#444"
                borderSize: 1

                topLeftRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
                topRightRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
                bottomLeftRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
                bottomRightRadius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8

                onTextChanged: {
                    if (root.sourceMode === 2) {
                        root.wallhavenQuery = text;
                    } else {
                        root.filterText = text;
                    }
                }

                onAccepted: {
                    if (root.sourceMode === 2) {
                        root.searchWallhaven(true);
                    }
                }
            }

            // Search button for Wallhaven
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
                visible: root.sourceMode === 2
                color: searchBtnMouse.containsMouse
                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                    : ThemeManager.selectedTheme?.colors?.primary.alpha(0.8) || "#5558e8"

                Text {
                    anchors.centerIn: parent
                    text: "󰍉"
                    font.pixelSize: 16
                    font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                    color: "#fff"
                }

                MouseArea {
                    id: searchBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.searchWallhaven(true)
                }
            }
        }

        // Wallhaven filters (only when Wallhaven is selected)
        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: root.sourceMode === 2

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
                        let label = sorts[root.wallhavenSorting] || "Top";
                        if (root.wallhavenSorting === "toplist") {
                            const range = root.topRangePresets.find(r => r.value === root.wallhavenTopRange);
                            label += " (" + (range ? range.name : root.wallhavenTopRange) + ")";
                        }
                        label += root.wallhavenOrder === "asc" ? " ↑" : " ↓";
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

                        // Sort + Order in one row each
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
                                    color: root.wallhavenSorting === sortOptionRect.modelData.value
                                        ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                        : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                                    border.color: root.wallhavenSorting === sortOptionRect.modelData.value
                                        ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                        : "transparent"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: sortOptionRect.modelData.name
                                        font.pixelSize: 10
                                        color: root.wallhavenSorting === sortOptionRect.modelData.value
                                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                            : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.wallhavenSorting = sortOptionRect.modelData.value;
                                            root.searchWallhaven(true);
                                        }
                                    }
                                }
                            }
                        }

                        // Order row
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
                                    color: root.wallhavenOrder === orderRect.modelData.value
                                        ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                        : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                                    border.color: root.wallhavenOrder === orderRect.modelData.value
                                        ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                        : "transparent"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: orderRect.modelData.name
                                        font.pixelSize: 10
                                        color: root.wallhavenOrder === orderRect.modelData.value
                                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                            : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.wallhavenOrder = orderRect.modelData.value;
                                            root.searchWallhaven(true);
                                        }
                                    }
                                }
                            }
                        }

                        // Time Range (only for toplist)
                        Column {
                            spacing: 4
                            visible: root.wallhavenSorting === "toplist"

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
                                        color: root.wallhavenTopRange === rangeRect.modelData.value
                                            ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                            : ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#222"
                                        border.color: root.wallhavenTopRange === rangeRect.modelData.value
                                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                            : "transparent"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: rangeRect.modelData.name
                                            font.pixelSize: 10
                                            color: root.wallhavenTopRange === rangeRect.modelData.value
                                                ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                                : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.wallhavenTopRange = rangeRect.modelData.value;
                                                root.searchWallhaven(true);
                                            }
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
                                property bool isOn: root.wallhavenCategory.charAt(catPopupRect.modelData.mask) === "1"
                                
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
                                        let cats = root.wallhavenCategory.split("");
                                        cats[catPopupRect.modelData.mask] = cats[catPopupRect.modelData.mask] === "1" ? "0" : "1";
                                        if (cats.join("") !== "000") {
                                            root.wallhavenCategory = cats.join("");
                                            root.searchWallhaven(true);
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
                border.color: root.wallhavenColor !== "" ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : "transparent"
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
                        color: root.wallhavenColor !== "" ? ("#" + root.wallhavenColor) : "transparent"
                        border.color: root.wallhavenColor === "" 
                            ? ThemeManager.selectedTheme?.colors?.subtleText || "#666" 
                            : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.wallhavenColor === "" ? "?" : ""
                            font.pixelSize: 9
                            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                        }
                    }

                    Text {
                        text: root.wallhavenColor === "" ? "Color" : root.colorPresets.find(c => c.hex === root.wallhavenColor)?.name || "Custom"
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.wallhavenColor !== ""
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
                                border.color: root.wallhavenColor === colorPresetRect.modelData.hex
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : (colorPresetRect.modelData.hex === "ffffff" || colorPresetRect.modelData.hex === "cccccc" ? "#999" : "transparent")
                                border.width: root.wallhavenColor === colorPresetRect.modelData.hex ? 2 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: colorPresetRect.modelData.hex === "" ? "✕" : ""
                                    font.pixelSize: 12
                                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        root.wallhavenColor = colorPresetRect.modelData.hex;
                                        colorPopup.close();
                                        root.searchWallhaven(true);
                                    }
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
                                        root.wallhavenColor = colorPresetRect.modelData.hex;
                                        colorPopup.close();
                                        root.searchWallhaven(true);
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
                border.color: root.wallhavenResolution !== "" ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : "transparent"
                border.width: 1

                Text {
                    id: resFilterText
                    anchors.centerIn: parent
                    text: root.wallhavenResolution === "" ? "Resolution" : root.resolutionPresets.find(r => r.value === root.wallhavenResolution)?.name || root.wallhavenResolution
                    font.pixelSize: 11
                    color: root.wallhavenResolution !== ""
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
                                color: root.wallhavenResolution === resPresetRect.modelData.value
                                    ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                                    : resPresetMouse.containsMouse
                                        ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.1) || "#222"
                                        : "transparent"
                                border.color: root.wallhavenResolution === resPresetRect.modelData.value
                                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                    : "transparent"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: resPresetRect.modelData.name + (resPresetRect.modelData.value !== "" ? "+" : "")
                                    font.pixelSize: 11
                                    color: root.wallhavenResolution === resPresetRect.modelData.value
                                        ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                                        : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
                                }

                                MouseArea {
                                    id: resPresetMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.wallhavenResolution = resPresetRect.modelData.value;
                                        resPopup.close();
                                        root.searchWallhaven(true);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Wallpaper Grid
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
            color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#1a1a2e"
            clip: true

            GridView {
                id: wallpaperGrid
                anchors.fill: parent
                anchors.margins: 8

                property int columns: root.compact ? 1 : 4
                cellWidth: (width - 16) / columns
                cellHeight: root.compact ? cellWidth * 0.5 + 24 : cellWidth * 0.6 + 28

                model: root.filteredWallpapers
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                onAtYEndChanged: {
                    if (atYEnd && root.sourceMode === 2 && !root.wallhavenLoading && root.wallhavenHasMore) {
                        root.loadMoreWallhaven();
                    }
                }

                delegate: Item {
                    id: wallpaperDelegate
                    required property int index
                    required property var modelData

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    property bool isWallhaven: root.sourceMode === 2
                    property string thumbUrl: isWallhaven ? modelData.thumb : ("file://" + modelData)
                    property string wallpaperPath: isWallhaven ? modelData.path : modelData
                    property string displayName: isWallhaven 
                        ? (modelData.resolution || modelData.id)
                        : modelData.split('/').pop()

                    Rectangle {
                        id: cardBg
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
                        color: itemMouseArea.containsMouse 
                            ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.15) || "#333"
                            : "transparent"
                        border.color: ThemeManager.currentWallpaper === wallpaperDelegate.wallpaperPath
                            ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                            : itemMouseArea.containsMouse 
                                ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.5) || "#555"
                                : "transparent"
                        border.width: ThemeManager.currentWallpaper === wallpaperDelegate.wallpaperPath ? 2 : 1

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: (ThemeManager.selectedTheme?.dimensions?.elementRadius || 8) - 2
                                color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV1 || "#111"
                                clip: true

                                Image {
                                    id: thumbImage
                                    anchors.fill: parent
                                    source: wallpaperDelegate.thumbUrl
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize: Qt.size(300, 200)
                                }

                                // Loading indicator
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.3) || "#333"
                                    visible: thumbImage.status === Image.Loading

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰑐"
                                        font.pixelSize: 14
                                        font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                                        color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"

                                        RotationAnimation on rotation {
                                            running: thumbImage.status === Image.Loading
                                            from: 0
                                            to: 360
                                            duration: 1000
                                            loops: Animation.Infinite
                                        }
                                    }
                                }

                                // Wallhaven badge
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 4
                                    height: 16
                                    width: favText.width + 8
                                    radius: 4
                                    color: "#000000aa"
                                    visible: wallpaperDelegate.isWallhaven && modelData.favorites > 0

                                    Text {
                                        id: favText
                                        anchors.centerIn: parent
                                        text: "♥ " + modelData.favorites
                                        font.pixelSize: 9
                                        color: "#ff6b6b"
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: wallpaperDelegate.displayName
                                font.pixelSize: 10
                                color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectWallpaper(wallpaperDelegate.modelData)
                        }
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: root.filteredWallpapers.length === 0 && !root.wallhavenLoading
                    text: {
                        if (root.sourceMode === 2) {
                            return qsTr("Search for wallpapers or click refresh to load top wallpapers");
                        }
                        if (root.sourceMode === 1 && root.customFolderPath === "") {
                            return qsTr("No custom folder selected.\nClick the folder icon to choose a folder.");
                        }
                        return qsTr("No wallpapers found");
                    }
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
                    horizontalAlignment: Text.AlignHCenter
                }

                // Loading state for Wallhaven
                Rectangle {
                    anchors.centerIn: parent
                    width: 48
                    height: 48
                    radius: 24
                    color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                    visible: root.wallhavenLoading && root.wallhavenWallpapers.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.pixelSize: 24
                        font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                        color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"

                        RotationAnimation on rotation {
                            running: root.wallhavenLoading
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }
            }

            // Load more indicator
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 8
                width: loadMoreText.width + 24
                height: 28
                radius: 14
                color: ThemeManager.selectedTheme?.colors?.primary.alpha(0.9) || "#6366f1"
                visible: root.sourceMode === 2 && root.wallhavenLoading && root.wallhavenWallpapers.length > 0

                Text {
                    id: loadMoreText
                    anchors.centerIn: parent
                    text: "Loading more..."
                    font.pixelSize: 11
                    color: "#fff"
                }
            }
        }
    }
}

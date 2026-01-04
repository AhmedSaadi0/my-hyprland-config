// components/WallpaperSelector.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/config"
import "root:/components/wallpaper_selector"

import "root:/windows/smart_capsule/logic"
import "root:/config/ConstValues.js" as C

// TODO: -> find a way to make this singltone
Item {
    id: root

    signal wallpaperSelected(string path)
    signal closeRequested

    MouseArea {
        anchors.fill: parent
        onClicked: event => event.accepted = true
    }

    property bool compact: width < 400
    property int sourceMode: 0 // 0: Local, 1: Downloaded, 2: Wallhaven
    property string filterText: ""

    property var localWallpapers: ThemeManager.localWallpapers
    property var downloadedWallpapers: ThemeManager.downloadedWallpapers
    property var activeDownloads: []

    ListModel {
        id: wallhavenModel
    }

    // Wallhaven settings
    property string wallhavenQuery: ""
    property string wallhavenCategory: "110"
    property string wallhavenPurity: "100"
    property string wallhavenSorting: "toplist"
    property string wallhavenOrder: "desc"
    property string wallhavenTopRange: "1M"
    property string wallhavenColor: ""
    property string wallhavenResolution: ""
    property int wallhavenPage: 1
    property bool wallhavenLoading: false
    property bool wallhavenHasMore: true

    function getFilteredList(sourceList) {
        if (!sourceList || sourceList.length === 0)
            return [];
        if (filterText === "")
            return sourceList;

        const searchLower = filterText.toLowerCase();
        return sourceList.filter(path => {
            const filename = (typeof path === 'string' ? path : path.path || "").split('/').pop().toLowerCase();
            return filename.includes(searchLower);
        });
    }

    Component.onCompleted: {
        ThemeManager.refreshAllWallpaperLists();
    }

    function searchWallhaven(resetPage) {
        if (wallhavenLoading)
            return;

        if (resetPage) {
            wallhavenPage = 1;
            wallhavenModel.clear();
            wallhavenHasMore = true;
        }

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

        ThemeManager.searchWallhaven(url);
    }

    function loadMoreWallhaven() {
        if (wallhavenLoading || !wallhavenHasMore)
            return;
        wallhavenPage++;
        searchWallhaven(false);
    }

    function selectWallpaper(wallpaperData) {
        if (sourceMode === 2) {
            if (typeof wallpaperData === 'object') {
                if (activeDownloads.length > 0) {
                    CapsuleManager.request({
                        priority: C.WARNING,
                        source: "WallpaperSelector",
                        icon: "󰅙",
                        text: "Please wait for the current download to finish",
                        playTone: false,
                        bgColor1: ThemeManager.selectedTheme.colors.error || "#cc3333"
                    });
                    return;
                }

                activeDownloads = [wallpaperData.id];

                CapsuleManager.request({
                    priority: C.TRANSIENT,
                    source: "WallpaperSelector",
                    icon: "󰇚",
                    text: "Starting download...",
                    withProgress: true
                });

                ThemeManager.downloadWallhaven(wallpaperData.id, wallpaperData.file_type, wallpaperData.path);
                return;
            }
        }
        const path = typeof wallpaperData === 'string' ? wallpaperData : wallpaperData.path;
        applyWallpaper(path);
    }

    function applyWallpaper(path) {
        ThemeManager.updateAndApplyTheme({
            "_wallpaper": path,
            "_enableDynamicWallpapers": false
        }, true);
        root.wallpaperSelected(path);
    }

    function handleRefresh() {
        if (sourceMode === 0) {
            ThemeManager.refreshLocalWallpapers();
        } else if (sourceMode === 1) {
            ThemeManager.refreshDownloadedWallpapers();
        } else {
            searchWallhaven(true);
        }
    }

    Connections {
        target: ThemeManager

        function onFetchingWallhavenWallpapersStarted() {
            root.wallhavenLoading = true;
        }

        function onWallhavenWallpapersFetched(response) {
            root.wallhavenLoading = false;
            if (response.data && Array.isArray(response.data)) {
                response.data.forEach(w => {
                    wallhavenModel.append({
                        "id": w.id,
                        "path": w.path,
                        "thumb": w.thumbs.large,
                        "resolution": w.resolution,
                        "file_type": w.file_type,
                        "favorites": w.favorites
                    });
                });

                if (response.meta) {
                    root.wallhavenHasMore = response.meta.current_page < response.meta.last_page;
                }
            }
        }

        function onWallhavenWallpapersError(errorDetails) {
            root.wallhavenLoading = false;
        }

        function onWallpaperDownloadFinished(filePath) {
            root.activeDownloads = [];
            root.applyWallpaper(filePath);
        }

        function onWallpaperDownloadError(errorDetails) {
            root.activeDownloads = [];
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Header Section
        WallpaperHeader {
            Layout.fillWidth: true
            isLoading: root.wallhavenLoading
            sourceMode: root.sourceMode
            onRefreshClicked: root.handleRefresh()
            onCloseClicked: root.closeRequested()
        }

        // Tabs Section
        SourceTabs {
            Layout.fillWidth: true
            currentSource: root.sourceMode
            onSourceSelected: index => {
                root.sourceMode = index;
                if (index === 2 && wallhavenModel.count === 0) {
                    root.searchWallhaven(true);
                }
            }
        }

        // Search Bar Section
        SearchBar {
            Layout.fillWidth: true
            sourceMode: root.sourceMode
            onFilterTextChanged: text => {
                if (root.sourceMode === 2) {
                    root.wallhavenQuery = text;
                } else {
                    root.filterText = text;
                }
            }
            onSearchRequested: root.searchWallhaven(true)
        }

        // Content Section with Animation
        SwipeView {
            id: viewPager
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.sourceMode
            clip: true
            interactive: false

            onCurrentIndexChanged: {
                if (root.sourceMode !== currentIndex) {
                    root.sourceMode = currentIndex;
                }
            }

            // Page 0: Local Wallpapers
            Item {
                WallpaperGrid {
                    anchors.fill: parent
                    wallpapers: root.getFilteredList(root.localWallpapers)
                    isWallhaven: false
                    loading: false
                    compact: root.compact
                    currentWallpaper: ThemeManager.currentWallpaper
                    downloadingList: []
                    emptyText: qsTr("No local wallpapers found")
                    onWallpaperClicked: wallpaperData => root.selectWallpaper(wallpaperData)
                }
            }

            // Page 1: Downloaded Wallpapers
            Item {
                WallpaperGrid {
                    anchors.fill: parent
                    wallpapers: root.getFilteredList(root.downloadedWallpapers)
                    isWallhaven: false
                    loading: false
                    compact: root.compact
                    currentWallpaper: ThemeManager.currentWallpaper
                    downloadingList: []
                    emptyText: qsTr("No downloaded wallpapers yet")
                    onWallpaperClicked: wallpaperData => root.selectWallpaper(wallpaperData)
                }
            }

            // Page 2: Wallhaven
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    WallhavenFilters {
                        Layout.fillWidth: true
                        sorting: root.wallhavenSorting
                        order: root.wallhavenOrder
                        topRange: root.wallhavenTopRange
                        category: root.wallhavenCategory
                        color: root.wallhavenColor
                        resolution: root.wallhavenResolution

                        onSortingSelected: value => {
                            root.wallhavenSorting = value;
                            root.searchWallhaven(true);
                        }
                        onOrderSelected: value => {
                            root.wallhavenOrder = value;
                            root.searchWallhaven(true);
                        }
                        onTopRangeSelected: value => {
                            root.wallhavenTopRange = value;
                            root.searchWallhaven(true);
                        }
                        onCategorySelected: value => {
                            root.wallhavenCategory = value;
                            root.searchWallhaven(true);
                        }
                        onColorSelected: value => {
                            root.wallhavenColor = value;
                            root.searchWallhaven(true);
                        }
                        onResolutionSelected: value => {
                            root.wallhavenResolution = value;
                            root.searchWallhaven(true);
                        }
                    }

                    WallpaperGrid {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        wallpapers: wallhavenModel
                        isWallhaven: true
                        loading: root.wallhavenLoading
                        compact: root.compact
                        currentWallpaper: ThemeManager.currentWallpaper
                        downloadingList: root.activeDownloads
                        emptyText: qsTr("Search for wallpapers or click refresh")

                        onWallpaperClicked: wallpaperData => root.selectWallpaper(wallpaperData)
                        onLoadMore: root.loadMoreWallhaven()
                    }
                }
            }
        }
    }
}

// components/WallpaperSelector.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "root:/themes"
import "root:/config"
import "root:/components/wallpaper_selector"

Item {
    id: root

    signal wallpaperSelected(string path)
    signal closeRequested

    // Catch clicks on blank areas to prevent closing the launcher
    MouseArea {
        anchors.fill: parent
        onClicked: event => event.accepted = true
    }

    property bool compact: width < 400
    property int sourceMode: 0 // 0 = Local, 1 = Downloaded, 2 = Wallhaven
    property string filterText: ""

    // Read wallpaper lists from ThemeManager
    property var localWallpapers: ThemeManager.localWallpapers
    property var downloadedWallpapers: ThemeManager.downloadedWallpapers
    property var wallhavenWallpapers: []

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

    property var currentWallpapers: {
        if (sourceMode === 0) return localWallpapers;
        if (sourceMode === 1) return downloadedWallpapers;
        return wallhavenWallpapers;
    }

    property var filteredWallpapers: {
        if (sourceMode === 2) return currentWallpapers;
        if (!currentWallpapers || currentWallpapers.length === 0) return [];
        if (filterText === "") return currentWallpapers;

        const searchLower = filterText.toLowerCase();
        return currentWallpapers.filter(path => {
            const filename = (typeof path === 'string' ? path : path.path || "").split('/').pop().toLowerCase();
            return filename.includes(searchLower);
        });
    }

    Component.onCompleted: {
        ThemeManager.refreshAllWallpaperLists();
    }

    function searchWallhaven(resetPage) {
        if (wallhavenLoading) return;
        
        if (resetPage) {
            wallhavenPage = 1;
            wallhavenWallpapers = [];
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
        if (wallhavenLoading || !wallhavenHasMore) return;
        wallhavenPage++;
        searchWallhaven(false);
    }

    function selectWallpaper(wallpaperData) {
        if (sourceMode === 2) {
            if (typeof wallpaperData === 'object') {
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

    // Listen to ThemeManager signals
    Connections {
        target: ThemeManager

        function onFetchingWallhavenWallpapersStarted() {
            root.wallhavenLoading = true;
        }

        function onWallhavenWallpapersFetched(response) {
            root.wallhavenLoading = false;
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

                if (response.meta) {
                    root.wallhavenHasMore = response.meta.current_page < response.meta.last_page;
                }
            }
        }

        function onWallhavenWallpapersError(errorDetails) {
            root.wallhavenLoading = false;
            console.error("WallpaperSelector: Wallhaven error -", errorDetails);
        }

        function onWallpaperDownloadFinished(filePath) {
            root.applyWallpaper(filePath);
        }

        function onWallpaperDownloadError(errorDetails) {
            console.error("WallpaperSelector: Download error -", errorDetails);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        WallpaperHeader {
            Layout.fillWidth: true
            isLoading: root.wallhavenLoading
            sourceMode: root.sourceMode
            onRefreshClicked: root.handleRefresh()
            onCloseClicked: root.closeRequested()
        }

        SourceTabs {
            Layout.fillWidth: true
            currentSource: root.sourceMode
            onSourceSelected: index => {
                root.sourceMode = index;
                if (index === 2 && root.wallhavenWallpapers.length === 0) {
                    root.searchWallhaven(true);
                }
            }
        }

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

        WallhavenFilters {
            Layout.fillWidth: true
            visible: root.sourceMode === 2

            sorting: root.wallhavenSorting
            order: root.wallhavenOrder
            topRange: root.wallhavenTopRange
            category: root.wallhavenCategory
            color: root.wallhavenColor
            resolution: root.wallhavenResolution

            onSortingSelected: value => { root.wallhavenSorting = value; root.searchWallhaven(true); }
            onOrderSelected: value => { root.wallhavenOrder = value; root.searchWallhaven(true); }
            onTopRangeSelected: value => { root.wallhavenTopRange = value; root.searchWallhaven(true); }
            onCategorySelected: value => { root.wallhavenCategory = value; root.searchWallhaven(true); }
            onColorSelected: value => { root.wallhavenColor = value; root.searchWallhaven(true); }
            onResolutionSelected: value => { root.wallhavenResolution = value; root.searchWallhaven(true); }
        }

        WallpaperGrid {
            Layout.fillWidth: true
            Layout.fillHeight: true

            wallpapers: root.filteredWallpapers
            isWallhaven: root.sourceMode === 2
            loading: root.wallhavenLoading
            compact: root.compact
            currentWallpaper: ThemeManager.currentWallpaper
            emptyText: {
                if (root.sourceMode === 2) {
                    return qsTr("Search for wallpapers or click refresh to load top wallpapers");
                }
                return qsTr("No wallpapers found");
            }

            onWallpaperClicked: wallpaperData => root.selectWallpaper(wallpaperData)
            onLoadMore: root.loadMoreWallhaven()
        }
    }
}

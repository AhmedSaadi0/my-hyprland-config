// components/WallpaperSelector.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "root:/themes"
import "root:/config"
import "root:/services"
import "root:/components/wallpaper_selector"

import "root:/windows/smart_capsule/logic"

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

    // --- إدارة التنزيلات المتعددة ---
    // قائمة معرفات الصور التي يتم تنزيلها حالياً (لتشغيل الـ Spinner في الكروت)
    property var activeDownloads: []

    // كائن لتخزين نية المستخدم لكل عملية تنزيل
    // المفتاح هو الـ ID والقيمة هي "apply" أو "save"
    property var downloadIntents: ({})

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

    // --- دوال مساعدة ---

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

    // --- دوال البحث في Wallhaven ---

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

        if (wallhavenSorting === "toplist")
            url += "&topRange=" + wallhavenTopRange;
        if (wallhavenQuery !== "")
            url += "&q=" + encodeURIComponent(wallhavenQuery);
        if (wallhavenColor !== "")
            url += "&colors=" + wallhavenColor;
        if (wallhavenResolution !== "")
            url += "&atleast=" + wallhavenResolution;
        url += "&page=" + wallhavenPage;

        ThemeManager.searchWallhaven(url);
    }

    function loadMoreWallhaven() {
        if (wallhavenLoading || !wallhavenHasMore)
            return;
        wallhavenPage++;
        searchWallhaven(false);
    }

    // --- المنطق الأساسي (Core Logic) ---

    // دالة بدء التنزيل (تدعم التعدد)
    function _initiateDownload(wallpaperData, intent) {
        // التحقق من أن الملف غير موجود في قائمة التنزيل الحالية لتجنب التكرار
        if (activeDownloads.indexOf(wallpaperData.id) !== -1) {
            CapsuleCoordinator.handleWallpaperDownloadAlreadyActive();
            return;
        }

        // تسجيل النية (تطبيق أم حفظ فقط)
        downloadIntents[wallpaperData.id] = intent;

        // إضافة الـ ID لقائمة التنزيلات النشطة (لإظهار الـ Spinner)
        let newDownloads = activeDownloads.slice(); // نسخ المصفوفة
        newDownloads.push(wallpaperData.id);
        activeDownloads = newDownloads;

        CapsuleCoordinator.handleWallpaperDownloadStarted(intent);

        ThemeManager.downloadWallhaven(wallpaperData.id, wallpaperData.file_type, wallpaperData.path);
    }

    // 1. منطق التحميل والتطبيق
    function handleDownloadAndApply(wallpaperData) {
        if (sourceMode === 2) {
            // Wallhaven: تنزيل بنية التطبيق
            if (typeof wallpaperData === 'object') {
                _initiateDownload(wallpaperData, "apply");
            }
        } else {
            // Local/Downloaded: تطبيق مباشر
            const path = typeof wallpaperData === 'string' ? wallpaperData : wallpaperData.path;
            applyWallpaper(path);
        }
    }

    // 2. منطق التحميل فقط
    function handleDownloadOnly(wallpaperData) {
        if (sourceMode === 2) {
            // Wallhaven: تنزيل بنية الحفظ
            if (typeof wallpaperData === 'object') {
                _initiateDownload(wallpaperData, "save");
            }
        } else {
            // Local: إشعار فقط
            CapsuleCoordinator.handleWallpaperLocalAlreadyAvailable();
        }
    }

    // 3. منطق المعاينة
    function handlePreview(wallpaperData) {
        let previewUrl = "";
        let fullUrl = "";
        let title = "";
        let screenName = "";

        const windowObj = root.QsWindow.window;
        if (windowObj && windowObj.screen) {
            screenName = windowObj.screen.name || "";
        }

        if (sourceMode === 2) {
            previewUrl = wallpaperData.thumb || wallpaperData.path || "";
            fullUrl = wallpaperData.path || previewUrl;
            title = wallpaperData.resolution || wallpaperData.id || "";
        } else {
            const path = typeof wallpaperData === 'string' ? wallpaperData : wallpaperData.path;
            fullUrl = "file://" + path;
            previewUrl = fullUrl;
            title = path.split('/').pop();
        }

        console.info("[WallpaperSelector] handlePreview", "screen:", screenName, "title:", title, "preview:", previewUrl, "full:", fullUrl);

        OverlayService.openImagePreview({
            previewSource: previewUrl,
            fullSource: fullUrl,
            title: title,
            previewData: wallpaperData,
            sourceMode: root.sourceMode,
            screenName: screenName
        });
    }

    function applyWallpaper(path) {
        ThemeManager.updateAndApplyTheme({
            "_desktopClockDepthEffectEnabled": false,
            "_desktopClockDepthOverlayPath": "",
            "_wallpaper": path,
            "_enableDynamicWallpapers": false
        }, true);
        root.wallpaperSelected(path);
    }

    function handleRefresh() {
        if (sourceMode === 0)
            ThemeManager.refreshLocalWallpapers();
        else if (sourceMode === 1)
            ThemeManager.refreshDownloadedWallpapers();
        else
            searchWallhaven(true);
    }

    // --- Connections ---

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
                        "thumb": (w.thumbs && (w.thumbs.large || w.thumbs.small || w.thumbs.original)) ? (w.thumbs.large || w.thumbs.small || w.thumbs.original) : w.path,
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
            // ملاحظة: لا نمسح التنزيلات النشطة هنا لأن الخطأ في البحث لا يعني توقف التنزيلات
        }

        function onWallpaperDownloadFinished(filePath) {
            // نحتاج لمعرفة أي ID انتهى بناءً على اسم الملف
            // ملاحظة: هذا يعتمد على أن اسم الملف يحتوي على الـ ID (وهو الغالب في Wallhaven)

            let finishedId = null;
            let remainingDownloads = [];

            // البحث في التنزيلات النشطة
            for (let i = 0; i < root.activeDownloads.length; i++) {
                let id = root.activeDownloads[i];
                // التحقق البسيط: هل اسم الملف يحتوي على الـ ID؟
                if (filePath.indexOf(id) !== -1) {
                    finishedId = id;
                } else {
                    remainingDownloads.push(id);
                }
            }

            // تحديث القائمة لإيقاف الـ Spinner
            if (finishedId) {
                root.activeDownloads = remainingDownloads;

                // التحقق من النية
                let intent = root.downloadIntents[finishedId];
                if (intent === "apply") {
                    root.applyWallpaper(filePath);
                } else {
                    CapsuleCoordinator.handleWallpaperSavedToDownloaded();
                }

                // تنظيف النية
                delete root.downloadIntents[finishedId];

                // تحديث القائمة المحلية
                ThemeManager.refreshDownloadedWallpapers();
            } else {
                // في حال لم نستطع التعرف على الـ ID من اسم الملف
                // نقوم بمسح التنزيلات القديمة جداً أو نتركها (هنا سنتركها لتفادي خطأ في الـ UI)
                // لكن لتحديث القائمة:
                ThemeManager.refreshDownloadedWallpapers();
            }
        }

        // onWallpaperDownloadError handled by CapsuleCoordinator
    }

    Connections {
        target: OverlayService

        function onImagePreviewApplyRequested(previewData, sourceMode) {
            console.info("[WallpaperSelector] onImagePreviewApplyRequested", "sourceMode:", sourceMode);
            OverlayService.close();

            if (sourceMode !== 2) {
                const path = typeof previewData === 'string' ? previewData : previewData.path;
                if (path)
                    root.applyWallpaper(path);
                return;
            }

            if (previewData) {
                root.handleDownloadAndApply(previewData);
            }
        }
    }

    // --- الواجهة الرسومية ---

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Header
        WallpaperHeader {
            Layout.fillWidth: true
            isLoading: root.wallhavenLoading
            sourceMode: root.sourceMode
            onRefreshClicked: root.handleRefresh()
            onCloseClicked: root.closeRequested()
        }

        // Tabs
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

        // Search Bar
        SearchBar {
            Layout.fillWidth: true
            sourceMode: root.sourceMode
            onFilterTextChanged: text => {
                if (root.sourceMode === 2)
                    root.wallhavenQuery = text;
                else
                    root.filterText = text;
            }
            onSearchRequested: root.searchWallhaven(true)
        }

        // Content
        SwipeView {
            id: viewPager
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.sourceMode
            clip: true
            interactive: false
            onCurrentIndexChanged: if (root.sourceMode !== currentIndex)
                root.sourceMode = currentIndex

            // Page 0: Local
            Item {
                WallpaperGrid {
                    anchors.fill: parent
                    wallpapers: root.getFilteredList(root.localWallpapers)
                    isWallhaven: false
                    compact: root.compact
                    currentWallpaper: ThemeManager.currentWallpaper
                    downloadingList: []
                    emptyText: qsTr("No local wallpapers found")

                    onWallpaperDownloadAndApply: wallpaperData => root.handleDownloadAndApply(wallpaperData)
                    onWallpaperPreview: wallpaperData => root.handlePreview(wallpaperData)
                    onWallpaperDownloadOnly: wallpaperData => console.log("Already Local")
                }
            }

            // Page 1: Downloaded
            Item {
                WallpaperGrid {
                    anchors.fill: parent
                    wallpapers: root.getFilteredList(root.downloadedWallpapers)
                    isWallhaven: false
                    compact: root.compact
                    currentWallpaper: ThemeManager.currentWallpaper
                    downloadingList: []
                    emptyText: qsTr("No downloaded wallpapers yet")

                    onWallpaperDownloadAndApply: wallpaperData => root.handleDownloadAndApply(wallpaperData)
                    onWallpaperPreview: wallpaperData => root.handlePreview(wallpaperData)
                    onWallpaperDownloadOnly: wallpaperData => console.log("Already Downloaded")
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

                        onWallpaperDownloadAndApply: wallpaperData => root.handleDownloadAndApply(wallpaperData)
                        onWallpaperDownloadOnly: wallpaperData => root.handleDownloadOnly(wallpaperData)
                        onWallpaperPreview: wallpaperData => root.handlePreview(wallpaperData)

                        onLoadMore: root.loadMoreWallhaven()
                    }
                }
            }
        }
    }
}

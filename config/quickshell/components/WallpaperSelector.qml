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

    // --- إدارة المعاينة ---
    property string previewImageUrl: ""
    property var currentPreviewData: null

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
            CapsuleManager.request({
                priority: C.WARNING,
                source: "WallpaperSelector",
                icon: "󰅙",
                text: "Already downloading this wallpaper",
                playTone: false
            });
            return;
        }

        // تسجيل النية (تطبيق أم حفظ فقط)
        downloadIntents[wallpaperData.id] = intent;

        // إضافة الـ ID لقائمة التنزيلات النشطة (لإظهار الـ Spinner)
        let newDownloads = activeDownloads.slice(); // نسخ المصفوفة
        newDownloads.push(wallpaperData.id);
        activeDownloads = newDownloads;

        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: "WallpaperSelector",
            icon: "󰇚",
            text: intent === "apply" ? "Downloading & Applying..." : "Download started...",
            withProgress: true
        });

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
            CapsuleManager.request({
                priority: C.INFO,
                source: "WallpaperSelector",
                icon: "󰄬",
                text: "Image is already available locally",
                playTone: false
            });
        }
    }

    // 3. منطق المعاينة (Popup)
    function handlePreview(wallpaperData) {
        // حفظ البيانات لاستخدامها لاحقاً في زر التطبيق
        root.currentPreviewData = wallpaperData;

        let url = "";
        if (sourceMode === 2) {
            // Wallhaven: استخدم الصورة المصغرة (thumb) للعرض السريع بدلاً من الأصلية
            // إذا لم تتوفر thumb نعود للأصلية كاحتياط
            url = wallpaperData.thumb || wallpaperData.path;
        } else {
            const path = typeof wallpaperData === 'string' ? wallpaperData : wallpaperData.path;
            url = "file://" + path; // رابط محلي
        }

        root.previewImageUrl = url;
        previewPopup.open();
    }

    function applyWallpaper(path) {
        ThemeManager.updateAndApplyTheme({
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
                        "thumb": w.thumbs.original,
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
                    CapsuleManager.request({
                        priority: C.INFO,
                        source: "WallpaperSelector",
                        icon: "󰄬",
                        text: "Saved to Downloaded Wallpapers",
                        playTone: true
                    });
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

        function onWallpaperDownloadError(errorDetails) {
            CapsuleManager.request({
                priority: C.ERROR,
                source: "WallpaperSelector",
                icon: "󰅙",
                text: "Download failed",
                bgColor1: ThemeManager.selectedTheme.colors.error || "#cc3333"
            });
        // كإجراء احترازي في حال الخطأ، يمكننا مسح القائمة إذا كنا متأكدين
        // لكن لسلامة التنزيلات المتعددة، سنتركها للمستخدم ليحاول مرة أخرى
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

    // --- نافذة المعاينة (Popup) ---
    Popup {
        id: previewPopup
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // خلفية الـ Popup (شفافة لتبدو كـ Overlay)
        background: Rectangle {
            color: "#cc000000"
            radius: 8
        }

        // محتوى المعاينة
        Item {
            anchors.fill: parent

            // الصورة الكبيرة
            Image {
                id: previewImg
                anchors.fill: parent
                anchors.margins: 20
                source: root.previewImageUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                mipmap: true

                // تحديد حجم الذاكرة المستخدم
                // هذا يمنع فك تشفير الصورة بحجم هائل إذا كانت محلية، ويحسن الأداء
                sourceSize.width: 1280
                sourceSize.height: 720
            }

            // مؤشر التحميل (للصور من النت)
            BusyIndicator {
                anchors.centerIn: parent
                running: previewImg.status === Image.Loading
                width: 64
                height: 64
            }

            // زر الإغلاق
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                width: 40
                height: 40
                radius: 20
                color: closeMouse.containsMouse ? "#ff4444" : "#44ffffff"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "white"
                    font.pixelSize: 18
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: previewPopup.close()
                }
            }

            // زر "تطبيق" من المعاينة (اختياري - ميزة إضافية)
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 20
                width: 140
                height: 40
                radius: 20
                color: ThemeManager.selectedTheme.colors.primary || "#6366f1"
                visible: previewImg.status === Image.Ready

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "󰄬"
                        font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
                        color: ThemeManager.selectedTheme.colors.onPrimary
                    }
                    Text {
                        text: "Apply Wallpaper"
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        font.bold: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        previewPopup.close();

                        // منطق ذكي: إذا كانت محلية طبقها، وإذا من النت قم بتحميل الأصلية
                        if (root.sourceMode !== 2) {
                            // محلي
                            let path = root.previewImageUrl.replace("file://", "");
                            root.applyWallpaper(path);
                        } else {
                            // Wallhaven:
                            // نستخدم currentPreviewData المخزنة لأنها تحتوي على ID و Path الأصلي
                            // بينما previewImageUrl يحتوي فقط على رابط الصورة المصغرة (thumb)
                            if (root.currentPreviewData) {
                                root.handleDownloadAndApply(root.currentPreviewData);
                            }
                        }
                    }
                }
            }
        }
    }
}

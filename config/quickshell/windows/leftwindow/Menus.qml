// windows/leftwindow/Menus.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "./todo" as Todo
import "./dashboard" as Dashboard
import "./monitoring" as Monitoring
import "./weather"
import "./applauncher"
import "./notifications"
import "./network"
import "./clipboard"
import "./ai"

import "root:/utils"
import "root:/config"
import "root:/themes"
import "root:/config/EventNames.js" as Events

StackView {
    id: stackView

    Layout.fillWidth: true
    Layout.fillHeight: true

    clip: true
    smooth: true

    property int currentIndex: 0
    readonly property int appLauncherIndex: 9

    property var _instantiatedPages: ({})
    property var _scrollable: null
    property real collapseProgress: 0
    property bool _scrollActive: false
    property real _lastContentY: 0
    property string _lastScrollDir: "none"
    readonly property int _headerCollapseDiff: 200

    readonly property int _collapseStart: 6
    readonly property int _collapseRelease: 2

    NibrasShellShortcut {
        id: recreateAllMenusShortcut
        name: "recreateAllMenus"
        onPressed: stackView.recreateAllMenus()
    }

    Component {
        id: dashboardComponent
        Dashboard.Dashboard {}
    }
    Component {
        id: notiListComponent
        NotificationsList {}
    }
    Component {
        id: weatherComponent
        WeatherMenu {}
    }
    Component {
        id: monitorComponent
        Monitoring.Main {}
    }
    Component {
        id: networkComponent
        WifiList {}
    }
    Component {
        id: clipboardComponent
        Clipboard {}
    }
    Component {
        id: aiChatComponent
        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: "soon ..."
            color: ThemeManager.selectedTheme.colors.onSurface
        }
    }
    Component {
        id: todoChatComponent
        Todo.TodoView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    Component {
        id: translationChatComponent
        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: "soon ..."
            color: ThemeManager.selectedTheme.colors.onSurface
        }
    }
    Component {
        id: appLauncherComponent
        SidebarLauncher {}
    }

    // ---------------------------------------------------------
    // Lazy Loading Logic
    // ---------------------------------------------------------
    function getPage(index) {
        let page = _instantiatedPages[index];

        // 1. التحقق مما إذا كانت الصفحة موجودة في الكاش
        if (page) {
            try {
                if (page.objectName === undefined && page !== null) {}

                // --- الإصلاحات ---
                page.visible = false; // إعادة تعيين الرؤية لبدء الحركة
                page.opacity = 1.0;
                page.scale = 1.0;
                page.y = 0;

                // هام جداً: إعادة تفعيل التفاعل للصفحة القادمة
                page.enabled = true;
                // هام جداً: رفع الصفحة لتكون فوق البقايا الشفافة
                page.z = 1;

                return page;
            } catch (e) {
                console.warn("Found dead object in cache for index:", index, "- Recreating it.");
                _instantiatedPages[index] = null;
            }
        }

        // --- كود الإنشاء ---
        let componentMap = {
            0: dashboardComponent,
            1: notiListComponent,
            2: weatherComponent,
            3: monitorComponent,
            4: networkComponent,
            5: clipboardComponent,
            6: todoChatComponent,
            7: translationChatComponent,
            8: aiChatComponent,
            9: appLauncherComponent
        };

        let selectedComponent = componentMap[index];

        if (selectedComponent) {
            if (selectedComponent.status !== Component.Ready) {
                console.error("Component not ready for index:", index, "status:", selectedComponent.status, "error:", selectedComponent.errorString());
            }
            let newPage = selectedComponent.createObject(stackView, {
                "visible": false,
                "StackView.visible": false
            });

            if (newPage) {
                _instantiatedPages[index] = newPage;
                newPage.opacity = 1.0;
                newPage.scale = 1.0;
                newPage.y = 0;
                // ضمان التفعيل
                newPage.enabled = true;
                newPage.z = 1;
                return newPage;
            }

            console.error("Failed to create page object for index:", index, "componentError:", selectedComponent.errorString());
        }

        console.warn("Error: requested page index not found or failed to create:", index);
        return null;
    }

    function recreateAllMenus() {
        let savedIndex = currentIndex;

        for (let idx in _instantiatedPages) {
            let obj = _instantiatedPages[idx];
            if (obj) {
                EventBus.clearOwner(obj);
                obj.visible = false;
                obj.destroy();
            }
        }
        _instantiatedPages = ({});

        // Re-init eager pages (same as Component.onCompleted)
        let eagerMap = {
            0: dashboardComponent,
            1: notiListComponent,
            3: monitorComponent,
            4: networkComponent
        };

        for (let idx in eagerMap) {
            let comp = eagerMap[idx];
            if (comp && comp.status === Component.Ready) {
                let page = comp.createObject(stackView, {
                    "visible": false
                });
                if (page) {
                    _instantiatedPages[idx] = page;
                    page.opacity = 1.0;
                    page.scale = 1.0;
                    page.y = 0;
                    page.enabled = true;
                    page.z = 1;
                }
            }
        }

        // Restore the saved page
        let savedPage = getPage(savedIndex);
        if (savedPage) {
            currentIndex = savedIndex;
            savedPage.visible = true;
            stackView.replace(savedPage);
            Qt.callLater(_attachToCurrentScrollable);
        }
    }

    function _isScrollable(item) {
        return item && item.contentY !== undefined && item.contentHeight !== undefined;
    }

    function _findScrollable(item) {
        if (!item)
            return null;

        if (_isScrollable(item))
            return item;

        if (item.contentItem && _isScrollable(item.contentItem))
            return item.contentItem;

        const kids = item.children || [];
        for (let i = 0; i < kids.length; i++) {
            let found = _findScrollable(kids[i]);
            if (found)
                return found;
        }
        return null;
    }

    function _updateScrollPosition(y) {
        const clamped = Math.max(0, y || 0);

        // التحقق الأساسي: هل العنصر قابل للسكرول أصلاً؟
        if (!_scrollable)
            return;

        // 1. حل مشكلة الارتداد (Loop):
        // إذا كنا في وضع التوسعة (progress 0)
        // يجب أن نتأكد أن المحتوى أطول من (ارتفاع العرض الحالي + الفرق الذي سيحدثه تصغير الهيدر)
        // وإلا فإننا سنصغر الهيدر، وسيصبح المحتوى عائماً، وسيعود الهيدر للكبر فوراً
        if (collapseProgress === 0) {
            // هل المحتوى يستحق التصغير؟
            if (_scrollable.contentHeight < (_scrollable.height + _headerCollapseDiff)) {
                return; // المحتوى قصير جداً، ابقِ الهيدر كبيراً
            }

            if (clamped >= _collapseStart)
                collapseProgress = 1;
        } else {
            // نحن في وضع التصغير (progress 1)
            // نتحقق من شروط العودة للتوسعة
            if (_scrollable.contentHeight <= _scrollable.height + 2) {
                if (clamped <= _collapseRelease && !_scrollActive)
                    collapseProgress = 0;
                return;
            }

            if (clamped <= _collapseRelease && !_scrollActive && _lastScrollDir === "up") {
                expandDelay.restart();
            }
        }
    }

    function _attachToCurrentScrollable() {
        const current = stackView.currentItem;
        _scrollable = _findScrollable(current);
        if (_scrollable)
            _updateScrollPosition(_scrollable.contentY);
        else
            _updateScrollPosition(0);
    }

    // ---------------------------------------------------------
    // التهيئة والأحداث
    // ---------------------------------------------------------
    Component.onCompleted: {
        // تحميل الصفحة الرئيسية فقط عند البدء
        let initialPage = getPage(0);
        if (initialPage) {
            initialPage.visible = true;
            stackView.push(initialPage);
        }

        // Init notiListComponent to start register
        const notificationCompoObj = notiListComponent.createObject(stackView, {
            "visible": false
        });
        _instantiatedPages[1] = notificationCompoObj;

        // Init monitorComponent to start register
        const monitorComponentObj = monitorComponent.createObject(stackView, {
            "visible": false
        });
        _instantiatedPages[3] = monitorComponentObj;

        // Init networkComponent to start register
        const networkComponentObj = networkComponent.createObject(stackView, {
            "visible": false
        });
        _instantiatedPages[4] = networkComponentObj;

        EventBus.on(Events.LEFT_MENU_IS_OPENED, function (newIndex) {
            if (newIndex < 0 || newIndex === currentIndex)
                return;

            // تحديد اتجاه الحركة
            if (newIndex > currentIndex) {
                stackView.replaceEnter = enterFromBottom;
                stackView.replaceExit = exitToTop;
            } else {
                stackView.replaceEnter = enterFromTop;
                stackView.replaceExit = exitToBottom;
            }

            let targetPage = getPage(newIndex);

            if (targetPage) {
                // قبل الاستبدال، نعطل تفاعل الصفحة القديمة فوراً
                if (stackView.currentItem) {
                    stackView.currentItem.enabled = false;
                    stackView.currentItem.z = 0; // إنزالها في الترتيب
                }

                currentIndex = newIndex;
                targetPage.visible = true;

                stackView.replace(targetPage);
                Qt.callLater(_attachToCurrentScrollable);

                if (newIndex === stackView.appLauncherIndex && typeof targetPage.gainFocus === "function") {
                    targetPage.gainFocus();
                }
            }
        }, stackView);
    }

    onCurrentItemChanged: Qt.callLater(_attachToCurrentScrollable)

    Connections {
        target: _scrollable
        function onContentYChanged() {
            if (_scrollable) {
                const dy = _scrollable.contentY - _lastContentY;
                if (dy > 0.5)
                    _lastScrollDir = "down";
                else if (dy < -0.5)
                    _lastScrollDir = "up";
                _lastContentY = _scrollable.contentY;

                if (_scrollable.contentY > _collapseRelease)
                    expandDelay.stop();
                _updateScrollPosition(_scrollable.contentY);
            }
        }
        function onContentHeightChanged() {
            if (_scrollable)
                _updateScrollPosition(_scrollable.contentY);
        }
        function onMovingChanged() {
            if (!_scrollable)
                return;
            _scrollActive = _scrollable.moving;
            if (_scrollActive && _scrollable.contentY >= _collapseStart) {
                collapseProgress = 1;
                expandDelay.stop();
            }
            if (!_scrollActive && collapseProgress === 1 && _scrollable.contentY <= _collapseRelease && _lastScrollDir === "up") {
                expandDelay.restart();
            }
        }
    }

    Timer {
        id: expandDelay
        interval: 140
        repeat: false
        onTriggered: {
            if (_scrollable && _scrollable.contentY <= _collapseRelease && !_scrollActive)
                collapseProgress = 0;
        }
    }

    // ---------------------------------------------------------
    // تأثيرات الحركة (Transitions)
    // ---------------------------------------------------------

    // 1. قادم من الأسفل (عند النزول في القائمة)
    Transition {
        id: enterFromBottom
        SequentialAnimation {
            // تهيئة القيم قبل البدء
            PropertyAction {
                property: "opacity"
                value: 0
            }
            PropertyAction {
                property: "scale"
                value: 0.95
            } // تكبير المقياس قليلاً ليبدو أهدأ
            PropertyAction {
                property: "y"
                value: stackView.height * 0.15
            } // تقليل المسافة من 0.6 إلى 0.15

            ParallelAnimation {
                // حركة الموضع: استخدام OutQuart يمنع الارتداد (Overshoot)
                NumberAnimation {
                    property: "y"
                    to: 0
                    duration: 350 // تقليل الوقت قليلاً لسرعة الاستجابة
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    property: "opacity"
                    to: 1
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    property: "scale"
                    to: 1.0
                    duration: 350
                    easing.type: Easing.OutQuart
                }
            }
        }
    }

    Transition {
        id: exitToTop
        ParallelAnimation {
            NumberAnimation {
                property: "y"
                to: -stackView.height * 0.15 // تقليل مسافة الخروج أيضاً لتتناسب مع الدخول
                duration: 250
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    // 2. قادم من الأعلى (عند الصعود في القائمة)
    Transition {
        id: enterFromTop
        SequentialAnimation {
            PropertyAction {
                property: "opacity"
                value: 0
            }
            PropertyAction {
                property: "scale"
                value: 0.95
            }
            PropertyAction {
                property: "y"
                value: -stackView.height * 0.15
            } // مسافة أقصر

            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    to: 0
                    duration: 350
                    easing.type: Easing.OutQuart // حركة ناعمة بدون ارتداد
                }
                NumberAnimation {
                    property: "opacity"
                    to: 1
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    property: "scale"
                    to: 1.0
                    duration: 350
                    easing.type: Easing.OutQuart
                }
            }
        }
    }

    Transition {
        id: exitToBottom
        ParallelAnimation {
            NumberAnimation {
                property: "y"
                to: stackView.height * 0.15
                duration: 250
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }
}

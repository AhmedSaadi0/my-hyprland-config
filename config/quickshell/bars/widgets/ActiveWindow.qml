import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets

import "root:/themes"
import "root:/config"
import "root:/utils"
import "root:/services"

Item {
    id: root

    // --- 1. الإعدادات والخصائص (Properties) ---
    readonly property var theme: ThemeManager.selectedTheme
    readonly property var activeToplevel: Hyprland.activeToplevel

    property int minWidth: App.topBarActiveWindowMinWidth
    property int maxWidth: App.topBarActiveWindowMaxWidth
    property int innerPadX: theme.dimensions.spacingLarge
    property int gap: theme.dimensions.spacingMedium

    property bool hasWindow: activeToplevel !== null
    // property bool isFullscreen: (activeToplevel !== undefined && activeToplevel.fullscreen !== undefined && hasWindow !== null) ? hasWindow && activeToplevel.fullscreen : false
    // property bool isFullscreen: (activeToplevel && hasWindow) ? activeToplevel.fullscreen : false
    property bool isFullscreen: (activeToplevel?.fullscreen && hasWindow) || false
    property real hover: 0.0
    property real contentScale: 1.0
    property point parallaxOffset: Qt.point(0, 0)

    // منطق جلب اسم الكلاس والعنوان
    property string currentClass: {
        if (!hasWindow)
            return "Desktop";
        if (activeToplevel.appId)
            return activeToplevel.appId;
        try {
            var rawData = activeToplevel.lastIpcObject;
            if (rawData && rawData.class)
                return rawData.class;
        } catch (e) {}
        return "Active Window";
    }

    property string currentTitle: (hasWindow && activeToplevel.title) ? activeToplevel.title : "Workspace"
    property string iconName: currentClass === "Active Window" ? "application-x-executable" : currentClass.toLowerCase()
    property string displayedIconClass: currentClass
    property string displayedIconSource: ""

    function resolveActiveIconSource(windowClass) {
        let iconKey = Helper.iconNameFromAppId(windowClass);
        let cached = IconService.getCached(iconKey);
        if (cached && cached !== "")
            return cached;
        return Helper.toImageSource(Quickshell.iconPath(iconKey, "application-x-executable"));
    }

    function applyDisplayedIcon(windowClass) {
        const nextClass = windowClass || "Active Window";
        const nextSource = resolveActiveIconSource(nextClass);
        displayedIconClass = nextClass;
        if (nextSource && nextSource !== "")
            displayedIconSource = nextSource;
    }

    // الحسابات الديناميكية للعرض
    implicitHeight: theme.dimensions.barWidgetsHeight
    implicitWidth: Math.max(minWidth, Math.min(maxWidth, calculatedWidth))
    property int calculatedWidth: innerPadX * 2 + 28 + gap + Math.min(titleMetrics.width, maxWidth - 100)

    property int topLeftRadius
    property int bottomLeftRadius

    onCurrentClassChanged: {
        iconChangeDebounce.restart();
        let iconKey = Helper.iconNameFromAppId(currentClass);
        IconService.requestResolve([iconKey, "application-x-executable"]);
    }

    Connections {
        target: IconService
        function onIconsResolved() {
            applyDisplayedIcon(displayedIconClass);
        }
    }

    Component.onCompleted: applyDisplayedIcon(currentClass)

    Timer {
        id: iconChangeDebounce
        interval: 300
        repeat: false
        onTriggered: applyDisplayedIcon(root.currentClass)
    }

    TextMetrics {
        id: titleMetrics
        text: root.currentTitle
        font.family: theme.typography.bodyFont
        font.pixelSize: theme.typography.small
        font.bold: true
    }

    // --- 2. الخلفية والتأثيرات (Background & Effects) ---
    Rectangle {
        id: bgCapsule
        anchors.fill: parent
        radius: theme.dimensions.elementRadius
        topLeftRadius: root.topLeftRadius
        bottomLeftRadius: root.bottomLeftRadius
        clip: true // يمنع خروج المحتوى (النص المتحرك) عن الحدود

        color: theme.colors.primary.alpha(0.7)

        // --- 3. المحتوى الأساسي (Main Content) ---
        RowLayout {
            id: contentLayout
            anchors.fill: parent
            // anchors.leftMargin: root.innerPadX
            anchors.rightMargin: root.innerPadX
            spacing: 0

            // تأثير حركة الـ Parallax والمقياس
            transform: [
                Translate {
                    x: root.parallaxOffset.x
                    y: root.parallaxOffset.y
                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                },
                Scale {
                    origin.x: bgCapsule.width / 2
                    origin.y: bgCapsule.height / 2
                    xScale: root.contentScale
                    yScale: root.contentScale
                    Behavior on xScale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            ]

            // حاوية الأيقونة
            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    topLeftRadius: root.topLeftRadius
                    bottomLeftRadius: root.bottomLeftRadius
                    color: theme.colors.primary.lighter(1.8)
                    opacity: 0.25
                }

                IconImage {
                    id: appIcon
                    anchors.fill: parent
                    anchors.margins: 2
                    anchors.leftMargin: 4
                    source: root.displayedIconSource

                    onSourceChanged: iconAnim.restart()
                    asynchronous: true
                    mipmap: true
                }
            }

            // منطقة النص (اللوحة الإعلانية المتحركة)
            Item {
                id: textContainer
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height
                clip: true // ضروري جداً لقص النص الزائد

                Label {
                    id: scrollingText
                    text: root.currentTitle
                    color: theme.colors.onPrimary
                    font: titleMetrics.font
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter

                    // تحديد ما إذا كان النص يحتاج للتحرك
                    readonly property bool isOverflowing: width > parent.width

                    // الأنيميشن الخاص بالتحريك (Marquee)
                    SequentialAnimation on x {
                        running: scrollingText.isOverflowing
                        loops: Animation.Infinite

                        PauseAnimation {
                            duration: 2000
                        } // انتظر قليلاً في البداية

                        NumberAnimation {
                            from: 0
                            to: -(scrollingText.width - textContainer.width)
                            duration: Math.max(2000, scrollingText.width * 20)
                            easing.type: Easing.InOutQuad
                        }

                        PauseAnimation {
                            duration: 2000
                        } // انتظر في النهاية

                        NumberAnimation {
                            to: 0
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }
                    }

                    // إذا لم يكن النص طويلاً، اجعله في المنتصف (اختياري)
                    anchors.horizontalCenter: isOverflowing ? undefined : parent.horizontalCenter
                }
            }
        }
    }

    // --- 5. أنيميشن الأيقونة عند التغيير ---
    SequentialAnimation {
        id: iconAnim
        NumberAnimation {
            target: appIcon
            property: "scale"
            from: 0.6
            to: 1.2
            duration: 200
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: appIcon
            property: "scale"
            to: 1.0
            duration: 100
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami // نحتاجه للوصول إلى ألوان الثيم في الرأس

import QtQuick.Dialogs

import "root:/components"
import "root:/themes"

MenuCard {
    id: root
    // width: 320

    property bool settingsExpanded: false
    readonly property int fixedHeight: (grid.implicitHeight + settingsHeader.height) * 2

    height: settingsExpanded ? settingsLayout.implicitHeight + padding + fixedHeight : fixedHeight

    title: "الثيمات والتخصيص"
    icon: ""

    // onSettingsExpandedChanged: function () {
    //     console.info(settingsExpanded);
    //     if (settingsExpanded) {
    //         contentItem.implicitHeight = 400;
    //     } else {
    //         contentItem.implicitHeight = null;
    //     }
    // }

    // ديالوج اختيار الألوان
    // ColorDialog {
    //     id: colorDialog
    //     title: "اختر اللون"
    //
    //     property var targetTheme: null
    //     property string targetPropertyName: ""
    //
    //     onAccepted: {
    //         if (targetTheme && targetPropertyName !== "") {
    //             targetTheme[targetPropertyName] = color;
    //         }
    //     }
    // }

    ColumnLayout {
        id: mainLayout

        // ===================================
        // 1. شبكة اختيار الثيمات الأساسية
        // ===================================
        GridLayout {
            id: grid
            columns: 3
            Layout.fillWidth: true

            MButton {
                text: "Colors"
                onClicked: ThemeManager.loadTheme("ColorsTheme")
                Layout.fillWidth: true
                iconText: ""
            }
            MButton {
                text: "Deer"
                onClicked: ThemeManager.loadTheme("DeerTheme")
                Layout.fillWidth: true
                iconText: ""
            }
            MButton {
                text: "M3 Dark"
                onClicked: ThemeManager.loadTheme("M3Dark")
                Layout.fillWidth: true
                iconText: "󰖔"
            }
            MButton {
                text: "Harmony"
                onClicked: ThemeManager.loadTheme("HarmonyTheme")
                Layout.fillWidth: true
                iconText: "󰔉"
            }
            MButton {
                text: "Dark"
                onClicked: ThemeManager.loadTheme("DarkTheme")
                Layout.fillWidth: true
                iconText: "󱀝"
            }
            MButton {
                text: "M3 Light"
                onClicked: ThemeManager.loadTheme("M3Light")
                Layout.fillWidth: true
                iconText: ""
            }
        }

        // فاصل بصري
        Rectangle {
            id: sperator
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            height: 1
            color: ThemeManager.selectedTheme.colors.topbarFgColorV1.alpha(0.2)
        }

        // ==================================================
        // 2. رأس قسم الإعدادات (الزر القابل للطي)
        // ==================================================

        Rectangle {
            id: settingsHeader
            Layout.fillWidth: true
            height: 30
            color: "transparent"
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Label {
                    text: "التخصيص المتقدم"
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }

                Item {
                    Layout.fillWidth: true
                }

                Label {
                    id: expandIcon
                    text: ""
                    font.family: "FantasqueSansM Nerd Font Propo"
                    font.pixelSize: 16
                    color: Kirigami.Theme.textColor
                    rotation: root.settingsExpanded ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.settingsExpanded = !root.settingsExpanded;
                }
            }
        }

        ColumnLayout {
            id: settingsLayout
            spacing: 12 // قللنا المسافة بين الحاويات قليلاً
            Layout.fillWidth: true

            // الجزء الخاص بالحركة يبقى كما هو
            height: root.settingsExpanded ? implicitHeight : 0
            opacity: root.settingsExpanded ? 1.0 : 0.0
            clip: true
            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuad
                }
            }

            // --- قسم الألوان والمظهر ---
            M3GroupBox {
                title: "الألوان والمظهر"
                Layout.fillWidth: true
                Layout.topMargin: 10 // هامش علوي فقط لأول عنصر

                // لا نضع ColumnLayout هنا، بل نضع المحتوى مباشرة

                // موديل الألوان
                property var colorModel: [
                    {
                        label: "اللون الأساسي:",
                        propName: "_primary"
                    },
                    {
                        label: "اللون الثانوي:",
                        propName: "_secondary"
                    }
                ]

                // Repeater لإنشاء أزرار الألوان
                Repeater {
                    model: colorModel
                    delegate: RowLayout {
                        // اجعل التخطيط يملأ عرض الحاوية بالكامل
                        Layout.fillWidth: true
                        spacing: 8

                        property color currentColor: root.currentTheme ? root.currentTheme[modelData.propName] : "black"

                        Label {
                            text: modelData.label
                            // اجعل النص يأخذ الحد الأدنى من المساحة
                            Layout.fillWidth: false
                        }

                        Button {
                            Layout.fillWidth: true // دع الزر يأخذ باقي المساحة
                            text: Qt.color(currentColor).toString()
                            onClicked: {
                                colorDialog.currentColor = currentColor;
                                colorDialog.targetTheme = root.currentTheme;
                                colorDialog.targetPropertyName = modelData.propName;
                                colorDialog.open();
                            }
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                color: currentColor
                                radius: 4
                                z: -1
                            }
                        }
                    }
                }

                // عنصر الشفافية
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "الشفافية العامة:"
                    }
                    Slider {
                        Layout.fillWidth: true // اجعل السلايدر يأخذ باقي المساحة
                        from: 0.1
                        to: 1.0
                        stepSize: 0.05
                        value: root.currentTheme ? root.currentTheme._alpha : 1.0
                        onValueChanged: if (root.currentTheme)
                            root.currentTheme._alpha = value
                    }
                }
            }

            // --- قسم الخلفيات ---
            M3GroupBox {
                title: "إعدادات الخلفية"
                Layout.fillWidth: true

                Switch {
                    Layout.fillWidth: true // اجعل كل Switch يملأ العرض
                    text: "تفعيل الخلفيات المتحركة"
                    checked: root.currentTheme ? root.currentTheme._enableDynamicWallpapers : false
                    onCheckedChanged: if (root.currentTheme)
                        root.currentTheme._enableDynamicWallpapers = checked
                }
                Switch {
                    Layout.fillWidth: true
                    text: "تفعيل الألوان من الخلفية"
                    checked: root.currentTheme ? root.currentTheme._enableDynamicColoring : false
                    onCheckedChanged: if (root.currentTheme)
                        root.currentTheme._enableDynamicColoring = checked
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "مسار مجلد الخلفيات"
                    text: root.currentTheme ? root.currentTheme._dynamicWallpapersPath : ""
                    enabled: root.currentTheme ? root.currentTheme._enableDynamicWallpapers : false
                    onAccepted: if (root.currentTheme)
                        root.currentTheme._dynamicWallpapersPath = text
                }
            }

            // --- قسم مكونات النظام ---
            M3GroupBox {
                title: "ثيمات المكونات"
                Layout.fillWidth: true

                TextField {
                    Layout.fillWidth: true // اجعل كل حقل نصي يملأ العرض
                    placeholderText: "اسم ثيم GTK"
                    text: root.currentTheme ? root.currentTheme._gtkTheme : ""
                    onAccepted: if (root.currentTheme)
                        root.currentTheme._gtkTheme = text
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "اسم حزمة الأيقونات"
                    text: root.currentTheme ? root.currentTheme._themeIcons : ""
                    onAccepted: if (root.currentTheme)
                        root.currentTheme._themeIcons = text
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "اسم ثيم Kvantum"
                    text: root.currentTheme ? root.currentTheme._kvantumTheme : ""
                    onAccepted: if (root.currentTheme)
                        root.currentTheme._kvantumTheme = text
                }
            }

            // --- قسم الإجراءات ---
            M3GroupBox {
                title: "الإجراءات"
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MButton {
                        Layout.fillWidth: true // اجعل الأزرار تتقاسم المساحة بالتساوي
                        text: "إعادة تعيين"
                        iconText: ""
                        onClicked: if (root.currentTheme)
                            ThemeManager.resetThemeToDefaults(root.currentTheme.themeName)
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "تطبيق"
                        iconText: ""
                        onClicked: if (root.currentTheme)
                            ThemeManager.applyTheme(root.currentTheme)
                    }
                }
                MButton {
                    Layout.fillWidth: true
                    text: "حفظ التعديلات"
                    iconText: ""
                    highlighted: true
                    onClicked: if (root.currentTheme)
                        ThemeManager.saveCustomThemeSettings(root.currentTheme)
                }
            }
        }
    }
}

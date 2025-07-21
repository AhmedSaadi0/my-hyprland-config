import QtQuick
import QtQuick.Dialogs
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

    readonly property var selectedTheme: ThemeManager.selectedTheme

    // onSettingsExpandedChanged: function () {
    //     console.info(settingsExpanded);
    //     if (settingsExpanded) {
    //         contentItem.implicitHeight = 400;
    //     } else {
    //         contentItem.implicitHeight = null;
    //     }
    // }

    ColorDialog {
        id: colorDialog
        title: "اختر اللون"
        objectName: "colorPickerDialog"

        property var targetedColor

        onAccepted: {
            console.info(targetedColor);
            selectedTheme._primary = selectedColor;
        }
    }

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
                id: colorsBox
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
                    model: colorsBox.colorModel
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        property color currentColor: root.selectedTheme._primary

                        Label {
                            text: modelData.label
                            Layout.preferredWidth: parent.width / 3
                            Layout.fillWidth: true
                        }

                        MButton {
                            Layout.preferredWidth: parent.width * 2 / 3
                            Layout.fillWidth: true
                            text: Qt.color(currentColor).toString()
                            onClicked: {
                                colorDialog.selectedColor = currentColor;
                                colorDialog.targetedColor = modelData.propName;
                                // colorDialog.targetTheme = root.selectedTheme;
                                // colorDialog.targetPropertyName = modelData.propName;
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
                        Layout.fillWidth: true
                        Layout.preferredWidth: parent.width / 3
                    }
                    Slider {
                        Layout.preferredWidth: parent.width * 2 / 3
                        Layout.fillWidth: true
                        from: 0.1
                        to: 1.0
                        stepSize: 0.05
                        value: root.selectedTheme ? root.selectedTheme._alpha : 1.0
                        onValueChanged: if (root.selectedTheme)
                            root.selectedTheme._alpha = value
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
                    checked: root.selectedTheme ? root.selectedTheme._enableDynamicWallpapers : false
                    onCheckedChanged: if (root.selectedTheme)
                        root.selectedTheme._enableDynamicWallpapers = checked
                }
                Switch {
                    Layout.fillWidth: true
                    text: "تفعيل الألوان من الخلفية"
                    checked: root.selectedTheme ? root.selectedTheme._enableDynamicColoring : false
                    onCheckedChanged: if (root.selectedTheme)
                        root.selectedTheme._enableDynamicColoring = checked
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "مسار مجلد الخلفيات"
                    text: root.selectedTheme ? root.selectedTheme._dynamicWallpapersPath : ""
                    enabled: root.selectedTheme ? root.selectedTheme._enableDynamicWallpapers : false
                    onAccepted: if (root.selectedTheme)
                        root.selectedTheme._dynamicWallpapersPath = text
                }
            }

            // --- قسم مكونات النظام ---
            M3GroupBox {
                title: "ثيمات المكونات"
                Layout.fillWidth: true

                TextField {
                    Layout.fillWidth: true // اجعل كل حقل نصي يملأ العرض
                    placeholderText: "اسم ثيم GTK"
                    text: root.selectedTheme ? root.selectedTheme._gtkTheme : ""
                    onAccepted: if (root.selectedTheme)
                        root.selectedTheme._gtkTheme = text
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "اسم حزمة الأيقونات"
                    text: root.selectedTheme ? root.selectedTheme._themeIcons : ""
                    onAccepted: if (root.selectedTheme)
                        root.selectedTheme._themeIcons = text
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "اسم ثيم Kvantum"
                    text: root.selectedTheme ? root.selectedTheme._kvantumTheme : ""
                    onAccepted: if (root.selectedTheme)
                        root.selectedTheme._kvantumTheme = text
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
                        onClicked: if (root.selectedTheme)
                            ThemeManager.resetThemeToDefaults(root.selectedTheme.themeName)
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "تطبيق"
                        iconText: ""
                        onClicked: if (root.selectedTheme)
                            ThemeManager.applyTheme(root.selectedTheme)
                    }
                }
                MButton {
                    Layout.fillWidth: true
                    text: "حفظ التعديلات"
                    iconText: ""
                    highlighted: true
                    onClicked: if (root.selectedTheme)
                        ThemeManager.saveCustomThemeSettings(root.selectedTheme)
                }
            }
        }
    }
}

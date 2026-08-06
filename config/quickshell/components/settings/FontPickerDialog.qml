// components/settings/FontPickerDialog.qml
// منتقي خطوط QML نقي (بدون QtWidgets) — يستبدل Qt.labs.platform.FontDialog
// الذي كان ينهار داخل عملية Quickshell عند التنقل في قائمة الخطوط (Qt 6.10 bug)

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import "root:/components"
import "root:/themes"

Controls.Popup {
    id: root

    // ================= الخصائص العامة =================
    property string currentFont: ""
    property string previewText: "The quick brown fox jumps over the lazy dog 0123456789"
    property int dialogWidth: 460
    property int dialogHeight: 560

    // ================= الإشارات =================
    signal fontPreviewed(string family)
    signal fontSelected(string family)
    signal canceled

    // ================= الحالة الداخلية =================
    property var _allFamilies: []
    property var _filteredFamilies: []
    property string _searchQuery: ""
    property bool _accepted: false
    property bool _suppressPreview: false

    readonly property var theme: ThemeManager.selectedTheme
    readonly property string currentFamily: {
        if (listView.currentIndex < 0 || listView.currentIndex >= _filteredFamilies.length)
            return "";
        return _filteredFamilies[listView.currentIndex];
    }

    width: dialogWidth
    height: dialogHeight
    modal: true
    closePolicy: Controls.Popup.CloseOnPressOutside
    padding: 16

    parent: Controls.Overlay.overlay
    anchors.centerIn: parent

    // ================= منطق القائمة =================
    function _rebuildModel() {
        var q = _searchQuery.toLowerCase();
        var result = [];
        for (var i = 0; i < _allFamilies.length; i++) {
            if (q === "" || _allFamilies[i].toLowerCase().indexOf(q) !== -1)
                result.push(_allFamilies[i]);
        }
        _filteredFamilies = result;
    }

    function _apply() {
        if (root.currentFamily === "")
            return;
        root._accepted = true;
        root.fontSelected(root.currentFamily);
        root.close();
    }

    Component.onCompleted: {
        // جلب كل عائلات الخطوط من Qt مباشرة (لا حوارات نظامية إطلاقاً)
        _allFamilies = Qt.fontFamilies();
        _allFamilies.sort();
        // إزالة التكرارات
        var unique = [];
        for (var i = 0; i < _allFamilies.length; i++) {
            if (unique.indexOf(_allFamilies[i]) === -1)
                unique.push(_allFamilies[i]);
        }
        _allFamilies = unique;
        _rebuildModel();
    }

    onOpened: {
        _accepted = false;
        searchField.text = "";
        _rebuildModel();
        var idx = _filteredFamilies.indexOf(root.currentFont);
        root._suppressPreview = true;
        listView.currentIndex = idx >= 0 ? idx : 0;
        listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
        listView.forceActiveFocus();
        // إعادة تفعيل المعاينة بعد ترتيب القائمة (لا معاينة عند الفتح فقط)
        Qt.callLater(() => root._suppressPreview = false);
    }

    onClosed: {
        if (!_accepted)
            root.canceled();
        _accepted = false;
    }

    Keys.onEscapePressed: root.close()

    // ================= المحتوى =================
    contentItem: ColumnLayout {
        spacing: 12

        // العنوان
        RowLayout {
            Layout.fillWidth: true

            Controls.Label {
                text: qsTr("Choose Font")
                font.bold: true
                font.pixelSize: 16
                color: root.theme.colors.onSurface
            }
            Item {
                Layout.fillWidth: true
            }
            Controls.Label {
                text: root.currentFamily !== "" ? root.currentFamily : "—"
                color: root.theme.colors.primary
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.maximumWidth: 200
            }
        }

        // حقل البحث
        Controls.TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            placeholderText: qsTr("Search fonts...")
            color: root.theme.colors.onSurface
            placeholderTextColor: root.theme.colors.onSurfaceVariant
            selectByMouse: true
            background: Rectangle {
                radius: root.theme.dimensions.shapeSmall
                color: root.theme.colors.surfaceContainerHigh.alpha(0.6)
                border.color: searchField.activeFocus ? root.theme.colors.primary : root.theme.colors.outlineVariant
                border.width: searchField.activeFocus ? 2 : 1
            }
            onTextChanged: {
                root._searchQuery = text;
                root._rebuildModel();
                if (listView.count > 0 && (listView.currentIndex < 0 || listView.currentIndex >= listView.count))
                    listView.currentIndex = 0;
            }
            onAccepted: root._apply()
        }

        // قائمة الخطوط (كل صف يُعرض بخطّه الخاص)
        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            background: Rectangle {
                radius: root.theme.dimensions.shapeSmall
                color: root.theme.colors.surfaceContainerLow.alpha(0.4)
            }

            ListView {
                id: listView
                model: root._filteredFamilies
                currentIndex: 0
                keyNavigationWraps: true
                highlightFollowsCurrentItem: true
                boundsBehavior: Flickable.StopAtBounds

                onCurrentIndexChanged: {
                    console.info("[Picker] index:", listView.currentIndex, "| family:", root.currentFamily, "| suppress:", root._suppressPreview);
                    if (root.opened && !root._suppressPreview && root.currentFamily !== "" && root.currentFamily !== root.currentFont)
                        root.fontPreviewed(root.currentFamily);
                }

                Keys.onReturnPressed: root._apply()
                Keys.onEnterPressed: root._apply()

                delegate: Rectangle {
                    required property string modelData
                    required property int index

                    width: listView.width
                    height: 46
                    radius: 6
                    color: listView.currentIndex === index ? root.theme.colors.primary.alpha(0.16) : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        // اسم الخط (بخط القراءة العادي للوضوح)
                        Text {
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            font.pixelSize: 12
                            color: listView.currentIndex === index ? root.theme.colors.primary : root.theme.colors.onSurface
                            elide: Text.ElideRight
                        }

                        // نص المعاينة الفعلي بخطّ العائلة نفسه
                        Text {
                            Layout.preferredWidth: 170
                            Layout.maximumWidth: 170
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            text: root.previewText
                            font.family: modelData
                            font.pixelSize: 16
                            color: listView.currentIndex === index ? root.theme.colors.primary : root.theme.colors.onSurface
                            elide: Text.ElideMiddle
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // إرسال مباشر من النقرة — يضمن القيمة الصحيحة دائماً حتى لو تأخر فحص currentFamily
                            listView.currentIndex = index;
                            if (root.opened && !root._suppressPreview && index >= 0 && index < root._filteredFamilies.length)
                                root.fontPreviewed(root._filteredFamilies[index]);
                        }
                        onDoubleClicked: {
                            listView.currentIndex = index;
                            if (index >= 0 && index < root._filteredFamilies.length)
                                root.fontSelected(root._filteredFamilies[index]);
                            root.close();
                        }
                    }
                }
            }
        }

        // شريط المعاينة الحية
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 8
            color: root.theme.colors.surfaceContainerHigh.alpha(0.6)
            border.color: root.theme.colors.primary.alpha(0.2)
            border.width: 1

            Text {
                anchors.centerIn: parent
                anchors.margins: 10
                text: root.previewText
                font.family: root.currentFamily !== "" ? root.currentFamily : root.currentFont
                font.pixelSize: 18
                color: root.theme.colors.onSurface
            }
        }

        // الأزرار
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item {
                Layout.fillWidth: true
            }

            MButton {
                text: qsTr("Cancel")
                Layout.preferredWidth: 90
                onClicked: root.close()
            }

            MButton {
                text: qsTr("Apply")
                Layout.preferredWidth: 90
                highlighted: true
                onClicked: root._apply()
            }
        }
    }
}

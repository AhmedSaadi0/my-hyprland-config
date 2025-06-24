import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ... داخل الواجهة الرئيسية ...

// حاوية الرأس الرئيسية
import "../notificatoin/C.qml" as ButtonSegment

RowLayout {
    width: parent.width
    padding: 10
    // لا نحتاج لـ spacing هنا لأننا سنتحكم بالهامش يدوياً

    // giả sử هذه هي المتغيرات المشابهة لـ SASS variables ($)
    readonly property color buttonBackgroundColor: "#333333"
    readonly property color buttonHoverColor: "#444444"
    readonly property color dividerColor: "#555555"
    readonly property color textColor: "white"
    readonly property int borderRadius: 8
    readonly property int buttonIconSize: 18
    readonly property int buttonTextSize: 14
    // --- مجموعة الأزرار المقسّمة (Segmented Button) ---
    // الفكرة: نستخدم Rectangle كحاوية بصرية لها حواف مستديرة
    // ونضع الأزرار الفعلية بداخلها. خاصية clip تضمن قص أي زوايا حادة للأزرار الداخلية.
    Rectangle {
        id: buttonGroup

        // الارتفاع يعتمد على حجم الأيقونة + هوامش
        height: buttonIconSize + 16
        // العرض يجمع عرض الأزرار بالداخل
        implicitWidth: clearButton.implicitWidth + muteButton.implicitWidth + divider.width

        radius: borderRadius // الحواف المستديرة الخارجية
        color: buttonBackgroundColor

        // الأهم: هذه الخاصية تقص محتويات الحاوية لتبقى ضمن حدودها المستديرة
        clip: true

        Row {
            anchors.fill: parent
            spacing: 0 // لا توجد مسافة بين الأزرار

            // 1. زر حذف الكل (على اليسار)
            ButtonSegment {
                id: clearButton
                text: "Clear All" // أو "strings.deleteAll"
                fontSize: buttonTextSize
                onClicked: {
                    console.log("Clear All Clicked");
                    // agsNotifications.clear();
                }
            }

            // 2. الفاصل الرأسي بين الزرين
            Rectangle {
                id: divider
                width: 1
                height: parent.height * 0.6 // لا يصل للحافة العلوية والسفلية تماماً
                anchors.verticalCenter: parent.verticalCenter
                color: dividerColor
            }

            // 3. زر كتم الصوت (على اليمين)
            ButtonSegment {
                id: muteButton
                text: "󰂚" // أيقونة كتم الصوت
                isIcon: true // نُعلِمه بأن هذا النص هو أيقونة
                onClicked: {
                    console.log("Mute Clicked");
                    // agsNotifications.dnd = !agsNotifications.dnd
                }
            }
        }
    }

    // --- العنوان ---
    Text {
        text: "Notifications" // هذا هو الـ "notification-header-label"
        color: textColor
        font.bold: true
        font.pixelSize: 16

        // لمحاكاة margin-left: 4.5rem
        // نستخدم Layout.leftMargin. القيمة تعتمد على حجم الخط الأساسي.
        // لنفترض أن 1rem = 16px، فإن 4.5rem = 72px.
        Layout.leftMargin: 72

        // للمحاذاة العمودية مع مجموعة الأزرار
        Layout.alignment: Qt.AlignVCenter
    }
}

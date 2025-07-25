import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ListView {
    id: listView
    anchors.fill: parent

    ListModel {
        id: clipboardModel
    }

    // متغيرات JavaScript للمساعدة في إدارة الردود غير المتزامنة
    property var receivedItems: ({}) // كائن لتخزين العناصر المستلمة مؤقتًا
    property int totalItems: 0      // العدد الإجمالي للعناصر المتوقعة

    model: clipboardModel
    delegate: Rectangle {
        // يمكن استبداله بـ Item أو أي عنصر مرئي آخر
        width: parent.width
        height: 60
        border.color: "lightgray"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            Text {
                text: model.text // "text" هو الدور (role) في ListModel
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Button {
                text: "Copy"
                onClicked:
                // هنا يجب عليك استدعاء وظيفة الكتابة إلى الحافظة
                // clipboard.setText(model.text)
                {}
            }

            Button {
                text: "Delete"
                onClicked:
                // clipboardModel.remove(index);
                {}
            }
        }
    }
}

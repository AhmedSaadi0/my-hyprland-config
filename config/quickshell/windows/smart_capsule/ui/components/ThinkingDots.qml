import QtQuick

Row {
    id: thinkingRoot
    spacing: 5
    
    property color color: "white"

    // نستخدم Repeater لإنشاء 3 نقاط
    Repeater {
        model: 3
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: thinkingRoot.color
            anchors.verticalCenter: parent.verticalCenter
            
            // حركة القفز المتتابعة
            SequentialAnimation on anchors.verticalCenterOffset {
                loops: Animation.Infinite
                running: true
                
                // تأخير الحركة بناءً على ترتيب النقطة (0، 1، 2) لعمل موجة
                PauseAnimation { duration: index * 100 }
                
                // القفز للأعلى
                NumberAnimation { 
                    to: -5
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                // النزول للأسفل
                NumberAnimation { 
                    to: 0
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                // انتظار قبل القفزة التالية
                PauseAnimation { duration: 600 }
            }
        }
    }
}

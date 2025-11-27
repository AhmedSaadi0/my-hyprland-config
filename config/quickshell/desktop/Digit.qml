// File: Digit.qml
import QtQuick 2.0

Item {
    id: container
    property int digit: 0
    property color digitColor: "white"

    readonly property real segmentThickness: height * 0.12
    readonly property real horizontalSegmentWidth: width * 0.9
    readonly property real verticalSegmentHeight: (height - (3 * segmentThickness)) / 2

    function isSegmentVisible(segment) {
        var segments = [[true, true, true, true, true, true, false]    // 0
            , [false, true, true, false, false, false, false] // 1
            , [true, true, false, true, true, false, true]    // 2
            , [true, true, true, true, false, false, true]    // 3
            , [false, true, true, false, false, true, true]    // 4
            , [true, false, true, true, false, true, true]    // 5
            , [true, false, true, true, true, true, true]    // 6
            , [true, true, true, false, false, false, false] // 7
            , [true, true, true, true, true, true, true]    // 8
            , [true, true, true, true, false, true, true]     // 9
        ];
        if (digit >= 0 && digit < segments.length) {
            return segments[digit][segment];
        }
        return false;
    }

    Rectangle {
        x: (container.width - horizontalSegmentWidth) / 2
        y: 0
        width: horizontalSegmentWidth
        height: segmentThickness
        color: container.digitColor
        visible: isSegmentVisible(0)
    }
    // الجزء 1: العلوي الأيمن
    Rectangle {
        x: container.width - segmentThickness - ((container.width - horizontalSegmentWidth) / 2)
        y: segmentThickness
        width: segmentThickness
        height: verticalSegmentHeight
        color: container.digitColor
        visible: isSegmentVisible(1)
    }
    // الجزء 2: السفلي الأيمن
    Rectangle {
        x: container.width - segmentThickness - ((container.width - horizontalSegmentWidth) / 2)
        y: segmentThickness * 2 + verticalSegmentHeight
        width: segmentThickness
        height: verticalSegmentHeight
        color: container.digitColor
        visible: isSegmentVisible(2)
    }
    // الجزء 3: السفلي
    Rectangle {
        x: (container.width - horizontalSegmentWidth) / 2
        y: container.height - segmentThickness
        width: horizontalSegmentWidth
        height: segmentThickness
        color: container.digitColor
        visible: isSegmentVisible(3)
    }
    // الجزء 4: السفلي الأيسر
    Rectangle {
        x: (container.width - horizontalSegmentWidth) / 2
        y: segmentThickness * 2 + verticalSegmentHeight
        width: segmentThickness
        height: verticalSegmentHeight
        color: container.digitColor
        visible: isSegmentVisible(4)
    }
    // الجزء 5: العلوي الأيسر
    Rectangle {
        x: (container.width - horizontalSegmentWidth) / 2
        y: segmentThickness
        width: segmentThickness
        height: verticalSegmentHeight
        color: container.digitColor
        visible: isSegmentVisible(5)
    }
    // الجزء 6: الأوسط
    Rectangle {
        x: (container.width - horizontalSegmentWidth) / 2
        y: (container.height - segmentThickness) / 2
        width: horizontalSegmentWidth
        height: segmentThickness
        color: container.digitColor
        visible: isSegmentVisible(6)
    }
}

import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
// import org.kde.kirigami as Kirigami

import "root:/themes"
import "root:/config"
import "root:/components"
import "root:/config/ConstValues.js" as C

Rectangle {
    id: root
    width: parent.width
    height: 270
    color: "transparent"

    property string wallpaper: ThemeManager.getCurrentWallpaper() !== undefined ? ThemeManager.getCurrentWallpaper() : ""

    MediaItem {
        id: backgroundImage
        source: wallpaper

        quality: "low"

        active: visible && (parent.parent ? parent.parent.visible : true)

        width: App.menuStyle == C.FLOATING ? ThemeManager.selectedTheme.dimensions.menuWidth - 24 : ThemeManager.selectedTheme.dimensions.menuWidth - 14
        height: 200

        anchors {
            topMargin: (ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 2) - 1
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        // layer.enabled: true
        // layer.smooth: true
        // layer.effect: OpacityMask {
        //     maskSource: Rectangle {
        //         width: backgroundImage.width
        //         height: backgroundImage.height
        //         radius: ThemeManager.selectedTheme.dimensions.elementRadius - 3
        //         visible: false // مهم: إخفاء مصدر القناع حتى لا يظهر مربع أبيض
        //     }
        // }
    }

    Rectangle {
        id: profileDetail
        width: backgroundImage.width
        height: 130
        // color: palette.accent.alpha(0.7)
        color: ThemeManager.selectedTheme.colors.topbarBgColorV2.alpha(0.7)
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        smooth: true
        anchors {
            top: backgroundImage.bottom
            left: backgroundImage.left
            right: backgroundImage.right
            topMargin: -(profileDetail.height / 2)
            leftMargin: 8
            rightMargin: 8
        }

        // layer.enabled: true
        // layer.effect: OpacityMask {
        //     // The mask source needs to be opaque where the content is visible
        //     // and transparent where the content should be cut out.
        //     // We use a Canvas to draw an opaque rectangle with a transparent circle hole.
        //     maskSource: Canvas {
        //         id: maskCanvas
        //         // The mask canvas should cover the area of the item being masked
        //         width: profileDetail.width
        //         height: profileDetail.height
        //         anchors.fill: profileDetail // Position the canvas exactly over the content
        //
        //         onPaint: {
        //             var ctx = getContext("2d");
        //             ctx.clearRect(0, 0, width, height); // Start with a clear (transparent) canvas
        //
        //             // 1. Draw an opaque rectangle covering the entire canvas area.
        //             //    This makes the mask opaque by default, so the content is visible.
        //             ctx.fillStyle = "white"; // Color doesn't matter for OpacityMask, only alpha
        //             ctx.fillRect(0, 0, width, height);
        //
        //             // 2. Set the composite operation to make subsequent drawing
        //             //    transparent where it overlaps with existing drawing.
        //             ctx.globalCompositeOperation = "destination-out";
        //
        //             // 3. Draw the shape that will punch the hole - the circle.
        //             var circleDiameter = 90;
        //             var circleRadius = circleDiameter / 2;
        //
        //             // Calculate the circle's center position relative to the canvas (which is
        //             // anchored to fill profileDetailContent, so canvas's top-left is content's top-left).
        //             // Horizontal center: center of content (width / 2)
        //             // Vertical center: The circle's center should be 45px *above* the top edge of the content.
        //             // The top edge of the content corresponds to y=0 in the canvas coordinates.
        //             // So the circle center y is 0. The circle radius is 45.
        //             // Drawing a circle centered at (x, 0) with radius 45 means its top edge is at y = 0 - 45 = -45.
        //             // This correctly positions the top of the 90px circle 45px above the content's top edge.
        //             var circleCenterX = width / 2;
        //             var circleCenterY = 0; // Center is on the top edge of the content
        //
        //             ctx.beginPath();
        //             // arc(centerX, centerY, radius, startAngle, endAngle)
        //             ctx.arc(circleCenterX, circleCenterY, circleRadius, 0, 2 * Math.PI);
        //             ctx.fillStyle = "black"; // Color doesn't matter for destination-out
        //             ctx.fill();
        //
        //             // Reset composite operation if needed later (good practice, though not needed here)
        //             // ctx.globalCompositeOperation = "source-over";
        //         }
        //     }
        // }
    }

    Image {
        id: profileImage
        width: 80
        height: 80
        source: App.profilePicture
        fillMode: Image.PreserveAspectCrop
        anchors {
            // anchors.centerIn: parent
            top: profileDetail.top
            horizontalCenter: profileDetail.horizontalCenter
            topMargin: -(profileImage.width / 2)
        }
        // layer.enabled: true
        // layer.effect: Shadow {
        //     alpha: 0.4
        // }
    }

    Text {
        id: titleText
        text: App.username
        font.pixelSize: 35
        font.family: "VIP Rawy Regular"
        // color: palette.base
        color: ThemeManager.selectedTheme.colors.topbarFgColorV2
        anchors {
            top: profileImage.bottom
            horizontalCenter: profileImage.horizontalCenter
        }
        smooth: true
        // layer.enabled: true
        // layer.effect:
        // Shadow {}
        // alpha: 0.5
        // radius: 3
    }

    Text {
        text: App.subtitle
        // color: palette.base
        color: ThemeManager.selectedTheme.colors.topbarFgColorV2
        anchors {
            top: titleText.bottom
            horizontalCenter: profileImage.horizontalCenter
        }
        smooth: true
        // layer.enabled: true
        // layer.effect:
        // Shadow {}
        // alpha: 0.5
    }
}

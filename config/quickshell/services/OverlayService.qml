pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string modeNone: ""
    readonly property string modeImagePreview: "imagePreview"

    property bool visible: false
    property string mode: modeNone
    property string targetScreenName: ""

    property string imagePreviewSource: ""
    property string imageFullSource: ""
    property string imageTitle: ""
    property var imagePreviewData: null
    property int imagePreviewSourceMode: 0

    signal imagePreviewApplyRequested(var previewData, int sourceMode)

    function openImagePreview(args) {
        const data = args || {};

        imagePreviewSource = data.previewSource || "";
        imageFullSource = data.fullSource || data.previewSource || "";
        imageTitle = data.title || "";
        imagePreviewData = data.previewData !== undefined ? data.previewData : null;
        imagePreviewSourceMode = data.sourceMode || 0;
        targetScreenName = data.screenName || "";
        mode = modeImagePreview;
        visible = true;

        console.info("[OverlayService] openImagePreview", "screen:", targetScreenName, "mode:", mode, "preview:", imagePreviewSource, "full:", imageFullSource);
    }

    function close() {
        console.info("[OverlayService] close", "screen:", targetScreenName, "mode:", mode);
        visible = false;
        mode = modeNone;
        targetScreenName = "";
        imagePreviewSource = "";
        imageFullSource = "";
        imageTitle = "";
        imagePreviewData = null;
        imagePreviewSourceMode = 0;
    }

    function requestImagePreviewApply() {
        console.info("[OverlayService] requestImagePreviewApply", "mode:", mode, "sourceMode:", imagePreviewSourceMode);
        imagePreviewApplyRequested(imagePreviewData, imagePreviewSourceMode);
    }
}

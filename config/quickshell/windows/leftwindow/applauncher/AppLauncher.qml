import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/themes"
import "root:/components"
import "./AppItem"

ScrollView {
    id: dashboardScroller

    height: parent.height
    width: parent.width

    clip: true
    contentWidth: availableWidth

    ScrollBar.vertical: StyledScrollBar {}
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    // This component reads all .desktop files and provides them as a model
    DesktopEntries {
        id: desktopEntriesModel

        // You can add filters if needed, for example, to exclude terminal apps
        // or settings entries by using categories. For now, we show all.
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        cellWidth: 120
        cellHeight: 100

        // Set the model to our dynamic DesktopEntries component
        model: desktopEntriesModel

        // The delegate will be instantiated for each entry in the model
        delegate: AppItem {
            // Bind the AppItem properties to the roles provided by the model.
            // The model provides roles like 'name', 'iconName', 'exec', 'comment', etc.
            appName: model.name // 'name' comes from the model
            appIcon: model.iconName // 'iconName' comes from the model

            // We don't need to pass 'exec' because we will call the launch method directly.

            // When an item is clicked, we ask the model to launch it using its index.
            onItemClicked: desktopEntriesModel.launch(model.index)
        }
    }
}

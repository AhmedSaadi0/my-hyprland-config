import QtQuick.Layouts
import QtQuick

import "../../components/monitors/"
import "root:/themes"

RowLayout {
    // anchors.fill: parent
    // width: 120
    spacing: 6

    Tempreture {
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    }
    Battery {
        glowIcon: false
        iconColor: ThemeManager.selectedTheme.colors.primary
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        backgroundColor: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
        foregroundColor: ThemeManager.selectedTheme.colors.primary
    }
    Ram {
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    }
    Cpu {
        iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    }
}

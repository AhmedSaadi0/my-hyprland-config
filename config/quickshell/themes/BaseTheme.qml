import QtQuick
import Quickshell

PersistentProperties {
    property int baseRadius: 15

    // --- Color Palette ---
    // Grouping all color definitions

    property var colors: QtObject {
        property color textBackgroundColor1: "#F905FF"
        property color textBackgroundColor2: "#20D2FD"

        // Foreground color for text
        property color textFg: "#09070f"

        // Add more color roles here for better organization and clarity
        // property color primary: "#..."
        // property color secondary: "#..."
        // property color background: "#..."
        // property color foreground: "#..."
        // property color border: "#..."
        // property color accent: "#..."
        // property color success: "#..."
        // property color warning: "#..."
        // property color error: "#..."
        // property color disabled: "#..."
        // property color buttonBackground: "#..."
        // property color buttonText: "#..."
        // ... etc. Define colors by their *role* rather than just a generic name
    }

    // --- Dimensions and Spacing ---
    // Grouping sizes, heights, widths, spacing, margins, etc.
    property var dimensions: QtObject {
        property int barHeight: 33
        property int barWidgetsHeight: 23

        // Radius for specific elements (can reference baseRadius)
        property int elementRadius: baseRadius // Renamed from radius for clarity

        // Common spacing values
        // property int spacing: 5
        // property int margin: 10
        // property int padding: 8
        // ...
    }

    // --- Typography ---
    // Grouping font-related properties
    property var typography: QtObject {
        // Font family names
        property string iconFont: "FantasqueSansM Nerd Font Propo"
        property string bodyFont: "Sans Serif" // Example
        property string headingFont: "Sans Serif" // Example

        // Font sizes
        // property int baseFontSize: 12
        // property int heading1Size: 24
        // property int bodyFontSize: baseFontSize

        // Font weights
        // property int bodyFontWeight: Font.Normal
        // property int headingFontWeight: Font.Bold
    }

    // --- System Integration Settings ---
    // Grouping properties that configure external system themes or assets

    property var systemSettings: QtObject {
        // Path to the wallpaper image for this theme
        property string wallpaper: "colors.png"

        // Strings used to configure external theme engines/settings
        property string qtThemeColor: "" // e.g., "light", "dark"
        property string qtThemeStyle: "" // e.g., "Fusion", "Material"
        property string kvantumTheme: "" // Name of Kvantum theme
        property string gtk3Theme: ""    // Name of GTK3 theme
        property string gtk4Theme: ""    // Name of GTK4 theme
        property string themeIcons: ""   // Name of icon theme
        property string themeMode: ""    // e.g., "light", "dark" - general mode indicator
        property string themefont: ""    // System-wide font setting string (if applicable)
        // ...
    }

    // --- Hyprland Configuration ---
    // Grouping properties specific to Hyprland window manager settings
    property var hyprConfiguration: QtObject {
        property int border_width: 2
        property string active_border: 'rgba(FDBBC4ff) rgba(ff00ffff) 0deg'
        property string inactive_border: 'rgba(59595900) 0deg'
        property int rounding: baseRadius // Can reference the theme's baseRadius
        property string drop_shadow: 'no'
        // Add all other relevant hyprland configuration properties here
        // property string layout: "..."
        // property string animation: "..."
        // ...
    }

    // Optional: Add a property to hold the theme's display name
    property string themeName: "Unnamed Theme"
}

import sys
import os
import json

def get_qt_styles():
    styles = []

    # Try PyQt6 first with proper QApplication initialization
    try:
        from PyQt6.QtWidgets import QApplication, QStyleFactory
        from PyQt6.QtCore import QCoreApplication
        # Use offscreen platform to avoid needing a display server
        app = QApplication(["", "-platform", "offscreen"])
        # Add common plugin paths
        plugin_paths = [
            "/usr/lib/qt6/plugins",
            "/usr/lib64/qt6/plugins",
            "/usr/local/lib/qt6/plugins"
        ]
        for p in plugin_paths:
            if os.path.isdir(p):
                QCoreApplication.addLibraryPath(p)
        styles = list(QStyleFactory.keys())
        if styles:
            return sorted(styles)
    except Exception as e:
        print(f"PyQt6 style detection failed: {e}", file=sys.stderr)

    # Try PySide6 as fallback
    try:
        from PySide6.QtWidgets import QApplication, QStyleFactory
        from PySide6.QtCore import QCoreApplication
        app = QApplication(["", "-platform", "offscreen"])
        plugin_paths = [
            "/usr/lib/qt6/plugins",
            "/usr/lib64/qt6/plugins",
            "/usr/local/lib/qt6/plugins"
        ]
        for p in plugin_paths:
            if os.path.isdir(p):
                QCoreApplication.addLibraryPath(p)
        styles = list(QStyleFactory.keys())
        if styles:
            return sorted(styles)
    except Exception as e:
        print(f"PySide6 style detection failed: {e}", file=sys.stderr)

    # Fallback: Scan Qt style plugin directories for .so files
    plugin_dirs = [
        "/usr/lib/qt6/plugins/styles",
        "/usr/lib/qt5/plugins/styles",
        "/usr/lib64/qt6/plugins/styles",
        "/usr/lib64/qt5/plugins/styles",
        os.path.expanduser("~/.local/lib/qt6/plugins/styles"),
        os.path.expanduser("~/.local/lib/qt5/plugins/styles"),
        "/usr/local/lib/qt6/plugins/styles",
        "/usr/local/lib/qt5/plugins/styles"
    ]
    for d in plugin_dirs:
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".so"):
                    # Extract style name from plugin filename (e.g., libkvantum.so -> kvantum)
                    style_name = f
                    if style_name.startswith("lib"):
                        style_name = style_name[3:]
                    if style_name.endswith(".so"):
                        style_name = style_name[:-3]
                    if style_name and style_name not in styles:
                        styles.append(style_name)
    return sorted(styles)

if __name__ == "__main__":
    styles = get_qt_styles()
    print(json.dumps(styles))

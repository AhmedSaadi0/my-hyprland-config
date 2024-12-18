import os


class CssThemeExporter:
    """Handles the generation and export of CSS files based on a color schema."""

    file_path = f'{os.path.expanduser("~")}/.config/ags/scss/themes/m3/dynamic.scss'

    TEMPLATE = """
    /* This file is created by ThemeService written by ahmedsaadi0 */
$primary: {primary};
$secondary: {secondary};
$tertiary: {tertiary};
$error: {error};
$background: {background};
$surface: {surface};
$surface-variant: {surfaceVariant};
$outlined: {outline};
$shadow: {shadow};
$inverseSurface: {inverseSurface};

$on-primary: {onPrimary};
$on-secondary: {onSecondary};
$on-tertiary: {onTertiary};
$on-error: {onError};
$on-background: {onBackground};

$primary-container: {primaryContainer};
$secondary-container: {secondaryContainer};
$tertiary-container: {tertiaryContainer};
$error-container: {errorContainer};

$on-primary-container: {onPrimaryContainer};
$on-secondary-container: {onSecondaryContainer};
$on-tertiary-container: {onTertiaryContainer};
$on-error-container: {onErrorContainer};
$on-surface: {onSurface};
$on-surface-variant: {onSurfaceVariant};

$inverseOnSurface: {inverseOnSurface};
$inversePrimary: {inversePrimary};

@import './main.scss';
""".strip()

    def __init__(self, color_schema):
        self.color_schema = color_schema

    def generate_css_classes(self):
        """Generates the needed CSS classes."""
        return self.TEMPLATE.format(**self.color_schema)

    def write_new_css(self, output_file=None):
        """Writes the generated classes into the CSS file."""

        self.file_path = output_file or self.file_path

        generated_css = self.generate_css_classes()

        with open(self.file_path, "w", encoding="utf-8") as file:
            file.write(generated_css)

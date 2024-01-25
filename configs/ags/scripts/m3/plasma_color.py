import os
from kde_material_you_colors.utils.m3_scheme_utils import (
    get_material_you_colors,
    export_schemes,
)
from kde_material_you_colors.schemeconfigs import ThemeConfig
from kde_material_you_colors.utils import plasma_utils, ksyntax_utils
from css_theme import CssThemeExporter
from kitty_theme import KittyThemeExporter
from pathlib import Path


class PlasmaColorExporter:
    extras = {}
    colors_dark = {}
    tones_error = {}
    base_text_states = {}
    toolbar_opacity_dark = 0

    file_path = f'{os.path.expanduser("~")}/.config/ags/scss/themes/m3/dynamic.scss'

    def __init__(self, wallpaper_data, ncolor, theme_mode):
        material_you_colors = get_material_you_colors(
            wallpaper_data, ncolor=ncolor, source_type="image"
        )

        path = Path(wallpaper_data)
        print(wallpaper_data)
        if not path.exists():
            return

        schemes = ThemeConfig(
            material_you_colors,
            wallpaper_data,
            0,
            0,
            0,
            0,
            None,
        )

        color_schema = material_you_colors.get("schemes").get(theme_mode)

        # Export css theme
        css_exporter = CssThemeExporter(color_schema)
        css_exporter.write_new_css()

        # Export kitty theme
        kitty = KittyThemeExporter(color_schema)
        kitty.write_new_kitty_theme()

        # Export Plasma theme
        export_schemes(schemes)
        plasma_utils.make_scheme(schemes)
        plasma_utils.apply_color_schemes(theme_mode == "light")
        ksyntax_utils.export_schemes(schemes)

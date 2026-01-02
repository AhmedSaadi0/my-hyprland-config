from pathlib import Path

from css_theme import CssThemeExporter
from kde_material_you_colors.schemeconfigs import ThemeConfig
from kde_material_you_colors.utils import (
    konsole_utils,
    ksyntax_utils,
    plasma_utils,
    pywal_utils,
)
from kde_material_you_colors.utils.m3_scheme_utils import (
    export_schemes,
    get_material_you_colors,
)
from kitty_theme import KittyThemeExporter


class ColorExporter:
    extras = {}
    colors_dark = {}
    tones_error = {}
    base_text_states = {}
    toolbar_opacity_dark = 0

    def __init__(
        self,
        wallpaper_data,
        ncolor,
        theme_mode,
        scheme_variant,
        chroma_mult,
        tone_mult,
    ):
        material_you_colors = get_material_you_colors(
            wallpaper_data=wallpaper_data,
            ncolor=ncolor,
            source_type="image",
            # 0 = Content
            # 1 = Expressive
            # 2 = Fidelity
            # 3 = Monochrome
            # 4 = Neutral
            # 5 = TonalSpot
            # 6 = Vibrant
            # 7 = Rainbow
            # 8 = FruitSalad
            scheme_variant=scheme_variant,
            chroma_mult=chroma_mult,
            tone_mult=tone_mult,
        )

        path = Path(wallpaper_data)
        if not path.exists():
            return

        schemes = ThemeConfig(
            material_you_colors,
            wallpaper_data,
            1,
            1,
            100,
            100,
            None,
        )
        # color_schema = material_you_colors.get("schemes").get(theme_mode)
        # self.export_css_theme(color_schema)
        # self.export_kitty_config(color_schema)
        export_schemes(schemes)
        self.export_plasma_color(schemes, theme_mode)
        self.export_konsole_theme(schemes, theme_mode)
        # self.export_and_apply_pywal_theme(schemes, theme_mode)

    def export_css_theme(self, color_schema):
        # Export css theme
        css_exporter = CssThemeExporter(color_schema)
        css_exporter.write_new_css()

    def export_plasma_color(self, schemes, theme_mode):
        # Export Plasma theme
        plasma_utils.make_scheme(schemes)
        plasma_utils.apply_color_schemes(theme_mode == "light")

    def export_kitty_config(self, color_schema):
        # Export kitty theme
        kitty = KittyThemeExporter(color_schema)
        kitty.write_new_kitty_theme()

    def export_konsole_theme(self, schemes, theme_mode="dark"):
        ksyntax_utils.export_schemes(schemes)
        konsole_utils.export_scheme(
            light=theme_mode == "light",
            pywal_light=theme_mode == "light",
            schemes=schemes,
            konsole_opacity=80,
            konsole_opacity_dark=80,
            dark_light=theme_mode != "light",
        )
        konsole_utils.apply_color_scheme()

    def export_and_apply_pywal_theme(self, schemes, theme_mode):
        """
        Exports and applies the color scheme for pywal.
        """
        is_light_theme = theme_mode == "light"

        # استدعاء الدالة باستخدام أسماء المتغيرات بشكل صريح لتجنب الأخطاء
        # وتفعيل خاصية التصدير عبر use_pywal=True
        pywal_utils.apply_schemes(
            schemes=schemes,
            light=is_light_theme,
            use_pywal=True,
        )

        print(
            f"Successfully exported and applied {'light' if is_light_theme else 'dark'} pywal theme."
        )

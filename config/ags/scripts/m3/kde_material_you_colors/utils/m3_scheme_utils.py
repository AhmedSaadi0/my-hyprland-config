import logging
import os
from .. import settings
from . import color_utils
from . import math_utils
from . import notify
from .wallpaper_utils import WallpaperReader
from .extra_image_utils import sourceColorsFromImage
from material_color_utilities_python.utils.theme_utils import *


def dict_to_rgb(dark_scheme):
    out = {}
    for key, color in dark_scheme.items():
        out.update({key: hexFromArgb(color)})
    return out


def tones_from_palette(palette):
    tones = {}
    for x in range(100):
        tones.update({x: palette.tone(x)})
    return tones


def get_custom_colors(custom_colors):
    colors = {}
    for custom_color in custom_colors:
        value = hexFromArgb(custom_color["color"]["value"])
        colors.update(
            {
                value: {
                    "color": dict_to_rgb(custom_color["color"]),
                    "value": hexFromArgb(custom_color["value"]),
                    "light": dict_to_rgb(custom_color["light"]),
                    "dark": dict_to_rgb(custom_color["dark"]),
                }
            },
        )
    return colors


def get_material_you_colors(wallpaper_data, ncolor, source_type):
    """Get material you colors from wallpaper or hex color using material-color-utility

    Args:
        wallpaper_data (tuple): wallpaper (type and data)
        ncolor (int): Alternative color number flag passed to material-color-utility
        source_type (str): image or color string passed to material-color-utility

    Returns:
        str: string data from python-material-color-utilities
    """

    try:
        seedColor = 0
        if source_type == "image":
            # open image file
            img = Image.open(wallpaper_data)
            # resize image proportionally
            basewidth = 128
            wpercent = basewidth / float(img.size[0])
            hsize = int((float(img.size[1]) * float(wpercent)))
            img = img.resize((basewidth, hsize), Image.Resampling.LANCZOS)
            # get best colors
            source_colors = sourceColorsFromImage(img, top=False)
            # close image file
            img.close()
            seed_color = source_colors[0]
        else:
            seed_color = argbFromHex(wallpaper_data)
            source_colors = [seed_color]

        # best colors
        best_colors = {}
        for i, color in enumerate(source_colors):
            best_colors.update({str(i): hexFromArgb(color)})
        # generate theme from seed color
        theme = themeFromSourceColor(seed_color)

        # Given a image, the alt color and hex color
        # return a selected color or a single color for hex code
        totalColors = len(best_colors)
        if ncolor and ncolor != None:
            ncolor = math_utils.clip(ncolor, 0, totalColors, 0)
        else:
            ncolor = 0

        if totalColors > ncolor:
            seedColor = hexFromArgb(source_colors[ncolor])
            seedNo = ncolor
        else:
            seedColor = hexFromArgb(source_colors[-1])
            seedNo = totalColors - 1
        if seedColor != 0:
            theme = themeFromSourceColor(argbFromHex(seedColor))

        dark_scheme = json.loads(theme["schemes"]["dark"].toJSON())
        light_scheme = json.loads(theme["schemes"]["light"].toJSON())
        primary_palete = theme["palettes"]["primary"]
        secondary_palete = theme["palettes"]["secondary"]
        tertiary_palete = theme["palettes"]["tertiary"]
        neutral_palete = theme["palettes"]["neutral"]
        neutral_variant_palete = theme["palettes"]["neutralVariant"]
        error_palette = theme["palettes"]["error"]
        custom_colors = theme["customColors"]

        materialYouColors = {
            "best": best_colors,
            "seed": {
                seedNo: hexFromArgb(theme["source"]),
            },
            "schemes": {
                "light": dict_to_rgb(light_scheme),
                "dark": dict_to_rgb(dark_scheme),
            },
            "palettes": {
                "primary": dict_to_rgb(tones_from_palette(primary_palete)),
                "secondary": dict_to_rgb(tones_from_palette(secondary_palete)),
                "tertiary": dict_to_rgb(tones_from_palette(tertiary_palete)),
                "neutral": dict_to_rgb(tones_from_palette(neutral_palete)),
                "neutralVariant": dict_to_rgb(
                    tones_from_palette(neutral_variant_palete)
                ),
                "error": dict_to_rgb(tones_from_palette(error_palette)),
            },
            "custom": [get_custom_colors(custom_colors)],
        }
        return materialYouColors

    except Exception as e:
        error = f"Error trying to get colors from {wallpaper_data}: {e}"
        logging.error(error)
        notify.send_notification("Could not get colors", error)
        return None


def get_color_schemes(wallpaper: WallpaperReader, ncolor=None):
    """Display best colors, allow to select alternative color,
    and make and apply color schemes for dark and light mode

    Args:
        wallpaper (tuple): wallpaper (type and data)
        ncolor (int): Alternative color number flag passed to material-color-utility

    Returns:

    """
    if wallpaper is not None:
        materialYouColors = None
        wallpaper_type = wallpaper.type
        wallpaper_data = wallpaper.source
        if wallpaper_type in ["image", "screenshot"]:
            if wallpaper_data and os.path.exists(wallpaper_data):
                if not os.path.isdir(wallpaper_data):
                    materialYouColors = get_material_you_colors(
                        wallpaper_data, ncolor=ncolor, source_type="image"
                    )
                else:
                    logging.error(f'"{wallpaper_data}" is a directory, aborting')

        elif wallpaper_type == "color":
            if wallpaper_data:
                wallpaper_data = color_utils.color2hex(wallpaper_data)
                materialYouColors = get_material_you_colors(
                    wallpaper_data, ncolor=ncolor, source_type=wallpaper_type
                )

        if materialYouColors is not None:
            try:
                if len(materialYouColors["best"]) > 1:
                    best_colors = f"Best colors: {settings.TERM_STY_BOLD}"

                    for i, color in materialYouColors["best"].items():
                        rgb = color_utils.hex2rgb(color)
                        preview = (
                            f"\033[38;2;{rgb[0]};{rgb[1]};{rgb[2]};1m{color} \033[0m"
                        )
                        best_colors += f"{settings.TERM_COLOR_DEF+settings.TERM_STY_BOLD}{i}:{preview}"
                    logging.info(best_colors[:-5])

                seed = materialYouColors["seed"]
                sedColor = list(seed.values())[0]
                seedNo = list(seed.keys())[0]
                rgb = color_utils.hex2rgb(sedColor)
                preview = f"\033[38;2;{rgb[0]};{rgb[1]};{rgb[2]};1m{sedColor}\033[0m"
                logging.info(
                    f"Using seed: {settings.TERM_COLOR_DEF+settings.TERM_STY_BOLD}{seedNo}:{preview}"
                )
                return materialYouColors

            except Exception as e:
                logging.exception(f"Error:\n{e}")
                return None


def export_schemes(schemes):
    """Export generated schemes to MATERIAL_YOU_COLORS_JSON

    Args:
        schemes (ThemeConfig): generated color schemes
    """
    colors = schemes.get_material_schemes()
    colors.update(
        {
            "extras": schemes.get_extras(),
            "pywal": {
                "light": schemes.get_wal_light_scheme(),
                "dark": schemes.get_wal_dark_scheme(),
            },
        }
    )

    with open(
        settings.MATERIAL_YOU_COLORS_JSON, "w", encoding="utf8"
    ) as material_you_colors:
        json.dump(colors, material_you_colors, indent=4, ensure_ascii=False)

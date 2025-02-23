from dataclasses import dataclass
from typing import Optional

from modules.utils.settings import get_settings

settings = get_settings()
WALLPAPER_PATH = settings.assets.get("wallpapers")


@dataclass
class HyprConfig:
    """
    Dataclass لتكوين Hyprland الخاص بالسمة.

    خصائص:
        border_width (int): عرض الحدود.
        active_border (str): لون الحدود النشطة (صيغة rgba أو زاوية تدرج).
        inactive_border (str): لون الحدود غير النشطة.
        rounding (int): مقدار زوايا النوافذ الدائرية.
        kitty (str): اسم ملف تكوين Kitty المستخدم مع هذه السمة.
        konsole (str): اسم ملف تعريف Konsole المستخدم مع هذه السمة.
    """

    border_width: int
    active_border: str
    inactive_border: str
    rounding: int
    kitty: str
    konsole: str


@dataclass
class Theme:
    """
    Dataclass لتعريف سمة كاملة.

    خصائص:
        wallpaper (str): مسار ملف الخلفية الثابت.
        css_theme (str): اسم ملف CSS الخاص بالسمة.
        plasma_color (str): اسم ملف نظام ألوان Plasma.
        qt_icon_theme (str): اسم مجموعة أيقونات Qt.
        kvantum_theme (str): اسم سمة Kvantum.
        gtk_theme (str): اسم سمة GTK3.
        gtk_icon_theme (str): اسم مجموعة أيقونات GTK.
        gtk_mode (str): وضع GTK ('dark' أو 'light').
        font_name (str): اسم الخط المستخدم.
        hypr (HyprConfig): تكوين Hyprland الخاص بالسمة.
        desktop_widget (Optional[str]): اسم الودجت سطح المكتب الخاص بالسمة (اختياري).
        dynamic (bool): هل السمة ديناميكية (تتغير الخلفية بمرور الوقت).
        wallpaper_path (Optional[str]): مسار مجلد الخلفيات الديناميكية (للسِمات الديناميكية).
        interval (Optional[int]): الفاصل الزمني لتغيير الخلفية الديناميكية بالملي ثانية (للسِمات الديناميكية).
    """

    wallpaper: str
    css_theme: str
    plasma_color: str
    qt_icon_theme: str
    kvantum_theme: str
    gtk_theme: str
    gtk_icon_theme: str
    gtk_mode: str
    font_name: str
    hypr: HyprConfig
    desktop_widget: Optional[str] = None
    dynamic: bool = False
    wallpaper_path: Optional[str] = None  # For dynamic themes
    interval: Optional[int] = None  # For dynamic themes


"""
وحدة تعريفات السمات.

تحتوي على dataclasses لتمثيل تكوينات Hyprland والسمات الكاملة،
بالإضافة إلى قاموس `ThemesDictionary` الذي يربط ثوابت السمات بكائنات `Theme`.
"""


black_hole_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/black-hole.png",
    css_theme="black-hole.scss",
    plasma_color="ArcMidnightDark.colors",
    qt_icon_theme="BeautySolar",
    kvantum_theme="Shades-of-purple",
    gtk_theme="Shades-of-purple",
    gtk_icon_theme="BeautySolar",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(FDBBC4ff) rgba(ff00ffff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=15,
        kitty="black_hole.conf",
        konsole="pinky",
    ),
    desktop_widget="BHWidget",
    dynamic=False,
)

win_20_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/win30.jpg",
    css_theme="win20.scss",
    plasma_color="ArcMidnightDark.colors",
    qt_icon_theme="BeautySolar",
    kvantum_theme="Shades-of-purple",
    gtk_theme="Shades-of-purple",
    gtk_icon_theme="BeautySolar",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(EB08FBff) rgba(16D7BAff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=12,
        kitty="win_20.conf",
        konsole="pinky",
    ),
    desktop_widget="Win20Widget",
    dynamic=False,
)

deer_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/deer.jpg",
    css_theme="deer.scss",
    plasma_color="BlueDeer.colors",
    qt_icon_theme="Vivid-Dark-Icons",
    kvantum_theme="Tellgo",
    gtk_theme="Kimi-dark",
    gtk_icon_theme="Vivid-Dark-Icons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(FDB4B7ff) rgba(A2E8FFff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=19,
        kitty="deer.conf",
        konsole="game",
    ),
    desktop_widget="DeerWidget",
    dynamic=False,
)

colors_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/colors.png",
    css_theme="colors.scss",
    plasma_color="AColors.colors",
    qt_icon_theme="Vivid-Dark-Icons",
    kvantum_theme="Shades-of-purple",
    gtk_theme="Shades-of-purple",
    gtk_icon_theme="Vivid-Dark-Icons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(FD02FFff) rgba(1ed4fdff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=19,
        kitty="colors.conf",
        konsole="pinky",
    ),
    desktop_widget="ColorWidget",
    dynamic=False,
)

siberian_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/tapet_Siberian.png",
    css_theme="siberian.scss",
    plasma_color="BlueDeer.colors",
    qt_icon_theme="NeonIcons",
    kvantum_theme="Tellgo",
    gtk_theme="Shades-of-purple",
    gtk_icon_theme="NeonIcons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(FDB4B7ff) rgba(A2E8FFff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=19,
        kitty="siberian.conf",
        konsole="game",
    ),
    desktop_widget="ColorWidget",
    dynamic=False,
)

material_you_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/pastel.jpg",
    css_theme="material-you.scss",
    plasma_color="MyMaterialYou.colors",
    qt_icon_theme="Zafiro-Nord-Dark-Black",
    kvantum_theme="a-m-you",
    gtk_theme="Cabinet-Light-Orange",
    gtk_icon_theme="kora-grey-light-panel",
    gtk_mode="light",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(678382ff) rgba(9d6c73ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=30,
        kitty="materialYou.conf",
        konsole="material-you",
    ),
    desktop_widget="MYWidget",
    dynamic=False,
)

game_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/game.png",
    css_theme="game.scss",
    plasma_color="ArcStarryDark.colors",
    qt_icon_theme="la-capitaine-icon-theme",
    kvantum_theme="Gradient-Dark-Kvantum",
    gtk_theme="Tokyonight-Dark-BL",
    gtk_icon_theme="la-capitaine-icon-theme",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(ffff7fff) rgba(ffaa7fff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=19,
        kitty="game.conf",
        konsole="game",
    ),
    desktop_widget=None,
    dynamic=False,
)

dark_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/dark.jpg",
    css_theme="dark.scss",
    plasma_color="DarkAGS.colors",
    qt_icon_theme="Infinity-Dark-Icons",
    kvantum_theme="WinSur-dark",
    gtk_theme="Tokyonight-Dark-BL",
    gtk_icon_theme="Infinity-Dark-Icons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(ff9a4cff) rgba(0080ffff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=8,
        kitty="dark.conf",
        konsole="dark",
    ),
    desktop_widget="Win20Widget",
    dynamic=False,
)

uniCat_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/unicat.png",
    css_theme="unicat.scss",
    plasma_color="Unicat.colors",
    qt_icon_theme="Vivid-Dark-Icons",
    kvantum_theme="Win10XOS-Concept",
    gtk_theme="Dracula",
    gtk_icon_theme="Vivid-Dark-Icons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(C6AAE8ff) rgba(F0AFE1ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=17,
        kitty="unicat.conf",
        konsole="unicat",
    ),
    desktop_widget="UnicatWidget",
    dynamic=False,
)

newCat_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/catMachup.jpg",
    css_theme="newCat.scss",
    plasma_color="NewCat.colors",
    qt_icon_theme="Gradient-Dark-Icons",
    kvantum_theme="Vivid-Dark-Kvantum",
    gtk_theme="Tokyonight-Dark-BL",
    gtk_icon_theme="Gradient-Dark-Icons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(ECBFBDff) rgba(F0AFE1ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=17,
        kitty="new_cat.conf",
        konsole="NewCat",
    ),
    desktop_widget="NewCatWidget",
    dynamic=False,
)

golden_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/golden.png",
    css_theme="golden.scss",
    plasma_color="Gold.colors",
    qt_icon_theme="Zafiro-Nord-Dark-Black",
    kvantum_theme="Canta-light",
    gtk_theme="Cabinet-Light-Orange",
    gtk_icon_theme="kora-grey-light-panel",
    gtk_mode="light",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(2C3041ff) rgba(611a15ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=17,
        kitty="golden.conf",
        konsole="material-you",
    ),
    desktop_widget="GoldenWidget",
    dynamic=False,
)

harmony_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/ign_wanderlust.jpg",
    css_theme="harmony.scss",
    plasma_color="Nordic.colors",
    qt_icon_theme="Windows11-red-dark",
    kvantum_theme="Sweet-Mars",
    gtk_theme="Nordic-darker-standard-buttons",
    gtk_icon_theme="Windows11-red-dark",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(BF616Bff) rgba(BF616Bff) 0deg",
        inactive_border="rgba(2E3440ff) 0deg",
        rounding=19,
        kitty="harmony.conf",
        konsole="harmony",
    ),
    desktop_widget="HarmonyWidget",
    dynamic=False,
)

circles_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/wall_arch.png",
    css_theme="circles.scss",
    plasma_color="Circles.colors",
    kvantum_theme="a-circles",
    qt_icon_theme="Vivid-Dark-Icons",
    gtk_theme="Nordic-darker-standard-buttons",
    gtk_icon_theme="Vivid-Dark-Icons",
    gtk_mode="dark",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(61AFEFff) rgba(7EC7A2ff) 0deg",
        inactive_border="rgba(00000000) 0deg",
        rounding=10,
        kitty="circles.conf",
        konsole="Circles",
    ),
    desktop_widget="CirclesWidget",
    dynamic=False,
)

white_flower_theme = Theme(
    wallpaper=f"{WALLPAPER_PATH}/white-flower.jpg",
    css_theme="white-flower.scss",
    plasma_color="MateriaYaruLight.colors",
    qt_icon_theme="Rowaita-Pink-Light",
    kvantum_theme="Mkos-BigSur-Transparent",
    gtk_theme="Jasper-Light-Dracula",
    gtk_icon_theme="Rowaita-Pink-Light",
    gtk_mode="light",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(678382ff) rgba(9d6c73ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=8,
        kitty="white_flower.conf",
        konsole="light",
    ),
    desktop_widget="WhiteFlower",
    dynamic=False,
)

dynamic_m3_dark_theme = Theme(
    wallpaper=None,
    css_theme=None,
    wallpaper_path="/path/to/dark/m3/wallpapers",  # Set your dark M3 wallpaper path
    dynamic=True,
    interval=15 * 60 * 1000,
    gtk_mode="dark",
    plasma_color="MateriaYaruDark.colors",
    kvantum_theme="Win10XOS-Concept",
    gtk_theme="Breeze-Dark",
    qt_icon_theme="BeautySolar",
    gtk_icon_theme="BeautySolar",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(678382ff) rgba(9d6c73ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=17,
        kitty="material-you.conf",
        konsole="MaterialYouAlt",
    ),
    desktop_widget="BHWidget",
)

dynamic_m3_light_theme = Theme(
    wallpaper=None,
    css_theme=None,
    wallpaper_path="/path/to/light/m3/wallpapers",
    dynamic=True,
    interval=15 * 60 * 1000,
    gtk_mode="light",
    plasma_color="MateriaYaruDark.colors",
    kvantum_theme="Arc",
    gtk_theme="Breeze",
    qt_icon_theme="BeautySolar",
    gtk_icon_theme="BeautySolar",
    font_name="JF Flat 11",
    hypr=HyprConfig(
        border_width=2,
        active_border="rgba(678382ff) rgba(9d6c73ff) 0deg",
        inactive_border="rgba(59595900) 0deg",
        rounding=17,
        kitty="material-you.conf",
        konsole="MaterialYouAlt",
    ),
    desktop_widget="BHWidget",
)


BLACK_HOLE_THEME = 0
DEER_THEME = 1
COLOR_THEME = 2
SIBERIAN_THEME = 3
MATERIAL_YOU = 4
WIN_20 = 5
GAME_THEME = 6
DARK_THEME = 7
UNICAT_THEME = 8
NEW_CAT_THEME = 9
GOLDEN_THEME = 10
HARMONY_THEME = 11
CIRCLES_THEME = 12
WHITE_FLOWER = 13
DYNAMIC_M3_DARK = 14
DYNAMIC_M3_LIGHT = 15

ThemesDictionary = {
    # السمات الديناميكية
    DYNAMIC_M3_DARK: dynamic_m3_dark_theme,
    DYNAMIC_M3_LIGHT: dynamic_m3_light_theme,
    # السمات الداكنة الثابتة
    BLACK_HOLE_THEME: black_hole_theme,
    DEER_THEME: deer_theme,
    COLOR_THEME: colors_theme,
    SIBERIAN_THEME: siberian_theme,
    GAME_THEME: game_theme,
    DARK_THEME: dark_theme,
    UNICAT_THEME: uniCat_theme,
    NEW_CAT_THEME: newCat_theme,
    HARMONY_THEME: harmony_theme,
    CIRCLES_THEME: circles_theme,
    WIN_20: win_20_theme,
    # السمات الفاتحة الثابتة
    MATERIAL_YOU: material_you_theme,
    GOLDEN_THEME: golden_theme,
    WHITE_FLOWER: white_flower_theme,
}

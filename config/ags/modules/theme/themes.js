import settings from '../settings.js';

const WALLPAPER_PATH = settings.assets.wallpapers;

const black_hole = {
    wallpaper: `${WALLPAPER_PATH}/black-hole.png`,
    css_theme: 'black-hole.scss',
    plasma_color: 'ArcMidnightDark.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'BeautySolar',
    kvantum_theme: 'Shades-of-purple',
    gtk_theme: 'Shades-of-purple',
    gtk_icon_theme: 'BeautySolar',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(FDBBC4ff) rgba(ff00ffff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 15,
        drop_shadow: 'no',
        kitty: 'black_hole.conf',
        konsole: 'pinky',
    },
    desktop_widget: 'BHWidget',
    dynamic: false,
};

const win_20 = {
    wallpaper: `${WALLPAPER_PATH}/win30.jpg`,
    css_theme: 'win20.scss',
    plasma_color: 'ArcMidnightDark.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'BeautySolar',
    kvantum_theme: 'Shades-of-purple',
    gtk_theme: 'Shades-of-purple',
    gtk_icon_theme: 'BeautySolar',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(EB08FBff) rgba(16D7BAff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 12,
        drop_shadow: 'no',
        kitty: 'win_20.conf',
        konsole: 'pinky',
    },
    desktop_widget: 'Win20Widget',
    dynamic: false,
};

const deer = {
    wallpaper: `${WALLPAPER_PATH}/deer.jpg`,
    // css_theme: "deer-m3.scss",
    css_theme: 'deer.scss',
    plasma_color: 'BlueDeer.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Vivid-Dark-Icons',
    kvantum_theme: 'Tellgo',
    gtk_theme: 'Kimi-dark',
    // gtk_theme: "Colorful-Dark-GTK",
    gtk_icon_theme: 'Vivid-Dark-Icons',
    // rofi_theme: "islamic_theme.rasi",
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(FDB4B7ff) rgba(A2E8FFff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 19,
        drop_shadow: 'no',
        kitty: 'deer.conf',
        konsole: 'game',
    },
    desktop_widget: 'DeerWidget',
    dynamic: false,
};

const colors = {
    wallpaper: `${WALLPAPER_PATH}/colors.png`,
    css_theme: 'colors.scss',
    plasma_color: 'AColors.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Vivid-Dark-Icons',
    kvantum_theme: 'Shades-of-purple',
    gtk_icon_theme: 'Vivid-Dark-Icons',
    gtk_theme: 'Shades-of-purple',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(FD02FFff) rgba(1ed4fdff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 19,
        drop_shadow: 'no',
        kitty: 'colors.conf',
        konsole: 'pinky',
    },
    desktop_widget: 'ColorWidget',
    dynamic: false,
};

const siberian = {
    wallpaper: `${WALLPAPER_PATH}/tapet_Siberian.png`,
    css_theme: 'siberian.scss',
    plasma_color: 'BlueDeer.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'NeonIcons',
    kvantum_theme: 'Tellgo',
    gtk_theme: 'Shades-of-purple',
    gtk_icon_theme: 'NeonIcons',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(FDB4B7ff) rgba(A2E8FFff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 19,
        drop_shadow: 'no',
        kitty: 'siberian.conf',
        konsole: 'game',
    },
    desktop_widget: 'ColorWidget',
    dynamic: false,
};

const materialYou = {
    wallpaper: `${WALLPAPER_PATH}/pastel.jpg`,
    css_theme: 'material-you.scss',
    plasma_color: 'MyMaterialYou.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Zafiro-Nord-Dark-Black',
    kvantum_theme: 'a-m-you',
    gtk_theme: 'Cabinet-Light-Orange',
    gtk_icon_theme: 'kora-grey-light-panel',
    gtk_mode: 'light',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 30,
        drop_shadow: 'no',
        kitty: 'materialYou.conf',
        konsole: 'material-you',
    },
    desktop_widget: 'MYWidget',
    dynamic: false,
};

const game = {
    wallpaper: `${WALLPAPER_PATH}/game.png`,
    css_theme: 'game.scss',
    plasma_color: 'ArcStarryDark.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'la-capitaine-icon-theme',
    kvantum_theme: 'Gradient-Dark-Kvantum',
    gtk_theme: 'Tokyonight-Dark-BL',
    gtk_icon_theme: 'la-capitaine-icon-theme',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(ffff7fff) rgba(ffaa7fff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 19,
        drop_shadow: 'no',
        kitty: 'game.conf',
        konsole: 'game',
    },
    desktop_widget: null,
    dynamic: false,
};

const dark = {
    wallpaper: `${WALLPAPER_PATH}/dark.jpg`,
    css_theme: 'dark.scss',
    plasma_color: 'DarkAGS.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Infinity-Dark-Icons',
    kvantum_theme: 'WinSur-dark',
    gtk_theme: 'Tokyonight-Dark-BL',
    gtk_icon_theme: 'Infinity-Dark-Icons',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(ff9a4cff) rgba(0080ffff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 8,
        drop_shadow: 'no',
        kitty: 'dark.conf',
        konsole: 'dark',
    },
    desktop_widget: 'Win20Widget',
    dynamic: false,
};

const uniCat = {
    wallpaper: `${WALLPAPER_PATH}/unicat.png`,
    css_theme: 'unicat.scss',
    plasma_color: 'Unicat.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Magma',
    kvantum_theme: 'Win10XOS-Concept',
    gtk_theme: 'Dracula',
    gtk_icon_theme: 'Magma',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(C6AAE8ff) rgba(F0AFE1ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 17,
        drop_shadow: 'no',
        kitty: 'unicat.conf',
        konsole: 'unicat',
    },
    desktop_widget: 'UnicatWidget',
    dynamic: false,
};

const newCat = {
    wallpaper: `${WALLPAPER_PATH}/catMachup.jpg`,
    css_theme: 'newCat.scss',
    plasma_color: 'NewCat.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Gradient-Dark-Icons',
    kvantum_theme: 'Vivid-Dark-Kvantum',
    gtk_theme: 'Tokyonight-Dark-BL',
    gtk_icon_theme: 'Gradient-Dark-Icons',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(ECBFBDff) rgba(F0AFE1ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 17,
        drop_shadow: 'no',
        kitty: 'new_cat.conf',
        konsole: 'NewCat',
    },
    desktop_widget: 'NewCatWidget',
    dynamic: false,
};

const golden = {
    wallpaper: `${WALLPAPER_PATH}/golden.png`,
    css_theme: 'golden.scss',
    plasma_color: 'Gold.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Zafiro-Nord-Dark-Black',
    kvantum_theme: 'Canta-light',
    gtk_theme: 'Cabinet-Light-Orange',
    gtk_icon_theme: 'kora-grey-light-panel',
    gtk_mode: 'light',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(2C3041ff) rgba(611a15ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 17,
        drop_shadow: 'no',
        kitty: 'golden.conf',
        konsole: 'material-you',
    },
    desktop_widget: 'GoldenWidget',
    dynamic: false,
};

const harmony = {
    wallpaper: `${WALLPAPER_PATH}/ign_wanderlust.jpg`,
    css_theme: 'harmony.scss',
    plasma_color: 'Nordic.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Windows11-red-dark',
    kvantum_theme: 'Sweet-Mars',
    gtk_theme: 'Nordic-darker-standard-buttons',
    gtk_icon_theme: 'Windows11-red-dark',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(BF616Bff) rgba(BF616Bff) 0deg',
        inactive_border: 'rgba(2E3440ff) 0deg',
        rounding: 19,
        drop_shadow: 'no',
        kitty: 'harmony.conf',
        konsole: 'harmony',
    },
    desktop_widget: 'HarmonyWidget',
    dynamic: false,
};

const circles = {
    wallpaper: `${WALLPAPER_PATH}/wall_arch.png`,
    css_theme: 'circles.scss',
    plasma_color: 'Circles.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    kvantum_theme: 'a-circles',
    qt_icon_theme: 'Vivid-Dark-Icons',
    gtk_theme: 'Nordic-darker-standard-buttons',
    gtk_icon_theme: 'Vivid-Dark-Icons',
    gtk_mode: 'dark',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(61AFEFff) rgba(7EC7A2ff) 0deg',
        inactive_border: 'rgba(00000000) 0deg',
        rounding: 10,
        drop_shadow: 'no',
        kitty: 'circles.conf',
        konsole: 'Circles',
    },
    desktop_widget: 'CirclesWidget',
    dynamic: false,
};

const whiteFlower = {
    wallpaper: `${WALLPAPER_PATH}/white-flower.jpg`,
    css_theme: 'white-flower.scss',
    plasma_color: 'MateriaYaruLight.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    qt_icon_theme: 'Rowaita-Pink-Light',
    kvantum_theme: 'Mkos-BigSur-Transparent',
    gtk_theme: 'Jasper-Light-Dracula',
    gtk_icon_theme: 'Rowaita-Pink-Light',
    gtk_mode: 'light',
    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 8,
        drop_shadow: 'no',
        kitty: 'white_flower.conf',
        konsole: 'light',
    },
    desktop_widget: 'WhiteFlower',
    dynamic: false,
};

const dynamicM3Dark = {
    wallpaper_path: settings.theme.darkM3WallpaperPath,
    dynamic: true,
    interval: 15 * 60 * 1000,
    gtk_mode: 'dark',

    plasma_color: 'MateriaYaruDark.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    kvantum_theme: 'Win10XOS-Concept', //
    gtk_theme: 'adw-gtk3',

    qt_icon_theme: 'BeautySolar',
    gtk_icon_theme: 'BeautySolar',

    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 17,
        drop_shadow: 'no',
        kitty: 'material-you.conf',
        konsole: 'MaterialYouAlt',
    },
    desktop_widget: null,
    desktop_widget: 'BHWidget',
};

const dynamicM3Light = {
    wallpaper_path: settings.theme.lightM3WallpaperPath,
    dynamic: true,
    interval: 15 * 60 * 1000,
    gtk_mode: 'light',

    plasma_color: 'MateriaYaruDark.colors',
    qt_5_style_theme: 'Breeze',
    qt_6_style_theme: 'kvantum',
    kvantum_theme: 'Arc',
    gtk_theme: 'adw-gtk3',

    qt_icon_theme: 'BeautySolar', //-Dark",
    gtk_icon_theme: 'BeautySolar', //-Dark",

    font_name: 'JF Flat 11',
    hypr: {
        border_width: 2,
        active_border: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactive_border: 'rgba(59595900) 0deg',
        rounding: 17,
        drop_shadow: 'no',
        kitty: 'material-you.conf',
        konsole: 'MaterialYouAlt',
    },
    // desktop_widget: null,
    desktop_widget: 'BHWidget',
};

export const BLACK_HOLE_THEME = 0;
export const DEER_THEME = 1;
export const COLOR_THEME = 2;
export const SIBERIAN_THEME = 3;
export const MATERIAL_YOU = 4;
export const WIN_20 = 5;
export const GAME_THEME = 6;
export const DARK_THEME = 7;
export const UNICAT_THEME = 8;
export const NEW_CAT_THEME = 9;
export const GOLDEN_THEME = 10;
export const HARMONY_THEME = 11;
export const CIRCLES_THEME = 12;
export const WHITE_FLOWER = 13;
export const DYNAMIC_M3_DARK = 14;
export const DYNAMIC_M3_LIGHT = 15;

const ThemesDictionary = {
    [BLACK_HOLE_THEME]: black_hole,
    [DEER_THEME]: deer,
    [COLOR_THEME]: colors,
    [SIBERIAN_THEME]: siberian,
    [MATERIAL_YOU]: materialYou,
    [WIN_20]: win_20,
    [GAME_THEME]: game,
    [DARK_THEME]: dark,
    [UNICAT_THEME]: uniCat,
    [NEW_CAT_THEME]: newCat,
    [GOLDEN_THEME]: golden,
    [HARMONY_THEME]: harmony,
    [CIRCLES_THEME]: circles,
    [WHITE_FLOWER]: whiteFlower,
    [DYNAMIC_M3_DARK]: dynamicM3Dark,
    [DYNAMIC_M3_LIGHT]: dynamicM3Light,
};

export default ThemesDictionary;

import settings from './settings';

const WALLPAPER_PATH = settings.assets.wallpapers;

// Re-define interfaces for better type safety, if not already defined in your project
interface ThemeHyprConfig {
    borderWidth: number;
    activeBorder: string;
    inactiveBorder: string;
    rounding: number;
    dropShadow?: 'yes' | 'no'; // Optional property as it's not in all themes but present in some (though always 'no' in provided data)
    kitty: string;
    konsole: string;
}

interface ThemeDefinition {
    wallpaper?: string; // Optional, as `dynamicM3Dark` and `dynamicM3Light` use wallpaperPath instead
    wallpaperPath?: string; // For dynamic themes
    cssTheme: string;
    plasmaColor: string;
    qt5styleTheme: string;
    qt6styleTheme: string;
    qtIconTheme: string;
    kvantumTheme: string;
    gtkTheme: string;
    gtkIconTheme: string;
    themeMode: 'dark' | 'light';
    fontName: string;
    hypr: ThemeHyprConfig;
    desktopWidget: string | null; // Can be null
    dynamic: boolean;
    interval?: number; // Optional, only for dynamic themes
}

const blackHole: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/black-hole.png`,
    cssTheme: 'black-hole.scss',
    plasmaColor: 'ArcMidnightDark.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'BeautySolar',
    kvantumTheme: 'Shades-of-purple',
    gtkTheme: 'Shades-of-purple',
    gtkIconTheme: 'BeautySolar',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(FDBBC4ff) rgba(ff00ffff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 15,
        dropShadow: 'no',
        kitty: 'blackHole.conf',
        konsole: 'pinky',
    },
    desktopWidget: 'BHWidget',
    dynamic: false,
};

const win_20: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/win30.jpg`,
    cssTheme: 'win20.scss',
    plasmaColor: 'ArcMidnightDark.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'BeautySolar',
    kvantumTheme: 'Shades-of-purple',
    gtkTheme: 'Shades-of-purple',
    gtkIconTheme: 'BeautySolar',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(EB08FBff) rgba(16D7BAff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 12,
        dropShadow: 'no',
        kitty: 'win_20.conf',
        konsole: 'pinky',
    },
    desktopWidget: 'Win20Widget',
    dynamic: false,
};

const deer: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/deer.jpg`,
    cssTheme: 'deer.scss', // Assuming you meant 'deer.scss' based on comment and other themes
    plasmaColor: 'BlueDeer.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Vivid-Dark-Icons',
    kvantumTheme: 'Tellgo',
    gtkTheme: 'Kimi-dark',
    gtkIconTheme: 'Vivid-Dark-Icons',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(FDB4B7ff) rgba(A2E8FFff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 19,
        dropShadow: 'no',
        kitty: 'deer.conf',
        konsole: 'game',
    },
    desktopWidget: 'DeerWidget',
    dynamic: false,
};

const colors: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/colors.png`,
    cssTheme: 'colors.scss',
    plasmaColor: 'AColors.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Vivid-Dark-Icons',
    kvantumTheme: 'Shades-of-purple',
    gtkIconTheme: 'Vivid-Dark-Icons',
    gtkTheme: 'Shades-of-purple',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(FD02FFff) rgba(1ed4fdff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 19,
        dropShadow: 'no',
        kitty: 'colors.conf',
        konsole: 'pinky',
    },
    desktopWidget: 'ColorWidget',
    dynamic: false,
};

const siberian: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/tapet_Siberian.png`,
    cssTheme: 'siberian.scss',
    plasmaColor: 'BlueDeer.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'NeonIcons',
    kvantumTheme: 'Tellgo',
    gtkTheme: 'Shades-of-purple',
    gtkIconTheme: 'NeonIcons',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(FDB4B7ff) rgba(A2E8FFff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 19,
        dropShadow: 'no',
        kitty: 'siberian.conf',
        konsole: 'game',
    },
    desktopWidget: 'ColorWidget', // Reused 'ColorWidget' - verify if this is correct
    dynamic: false,
};

const materialYou: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/pastel.jpg`,
    cssTheme: 'material-you.scss',
    plasmaColor: 'MyMaterialYou.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Zafiro-Nord-Dark-Black',
    kvantumTheme: 'a-m-you',
    gtkTheme: 'Cabinet-Light-Orange',
    gtkIconTheme: 'kora-grey-light-panel',
    themeMode: 'light',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 30,
        dropShadow: 'no',
        kitty: 'materialYou.conf',
        konsole: 'material-you',
    },
    desktopWidget: 'MYWidget',
    dynamic: false,
};

const game: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/game.png`,
    cssTheme: 'game.scss',
    plasmaColor: 'ArcStarryDark.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'la-capitaine-icon-theme',
    kvantumTheme: 'Gradient-Dark-Kvantum',
    gtkTheme: 'Tokyonight-Dark-BL',
    gtkIconTheme: 'la-capitaine-icon-theme',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(ffff7fff) rgba(ffaa7fff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 19,
        dropShadow: 'no',
        kitty: 'game.conf',
        konsole: 'game',
    },
    desktopWidget: null,
    dynamic: false,
};

const dark: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/dark.jpg`,
    cssTheme: 'dark.scss',
    plasmaColor: 'DarkAGS.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Infinity-Dark-Icons',
    kvantumTheme: 'WinSur-dark',
    gtkTheme: 'Tokyonight-Dark-BL',
    gtkIconTheme: 'Infinity-Dark-Icons',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(ff9a4cff) rgba(0080ffff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 8,
        dropShadow: 'no',
        kitty: 'dark.conf',
        konsole: 'dark',
    },
    desktopWidget: 'Win20Widget', // Reused 'Win20Widget' - verify if this is correct
    dynamic: false,
};

const uniCat: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/unicat.png`,
    cssTheme: 'unicat.scss',
    plasmaColor: 'Unicat.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Vivid-Dark-Icons',
    kvantumTheme: 'Win10XOS-Concept',
    gtkTheme: 'Dracula',
    gtkIconTheme: 'Vivid-Dark-Icons',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(C6AAE8ff) rgba(F0AFE1ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 17,
        dropShadow: 'no',
        kitty: 'unicat.conf',
        konsole: 'unicat',
    },
    desktopWidget: 'UnicatWidget',
    dynamic: false,
};

const newCat: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/catMachup.jpg`,
    cssTheme: 'newCat.scss',
    plasmaColor: 'NewCat.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Gradient-Dark-Icons',
    kvantumTheme: 'Vivid-Dark-Kvantum',
    gtkTheme: 'Tokyonight-Dark-BL',
    gtkIconTheme: 'Gradient-Dark-Icons',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(ECBFBDff) rgba(F0AFE1ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 17,
        dropShadow: 'no',
        kitty: 'newCat.conf',
        konsole: 'NewCat',
    },
    desktopWidget: 'NewCatWidget',
    dynamic: false,
};

const golden: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/golden.png`,
    cssTheme: 'golden.scss',
    plasmaColor: 'Gold.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Zafiro-Nord-Dark-Black',
    kvantumTheme: 'Canta-light',
    gtkTheme: 'Cabinet-Light-Orange',
    gtkIconTheme: 'kora-grey-light-panel',
    themeMode: 'light',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(2C3041ff) rgba(611a15ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 17,
        dropShadow: 'no',
        kitty: 'golden.conf',
        konsole: 'material-you', // Reused 'material-you' - verify if this is correct
    },
    desktopWidget: 'GoldenWidget',
    dynamic: false,
};

const harmony: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/ignWanderlust.jpg`,
    cssTheme: 'harmony.scss',
    plasmaColor: 'Nordic.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Windows11-red-dark',
    kvantumTheme: 'Sweet-Mars',
    gtkTheme: 'Nordic-darker-standard-buttons',
    gtkIconTheme: 'Windows11-red-dark',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(BF616Bff) rgba(BF616Bff) 0deg',
        inactiveBorder: 'rgba(2E3440ff) 0deg',
        rounding: 19,
        dropShadow: 'no',
        kitty: 'harmony.conf',
        konsole: 'harmony',
    },
    desktopWidget: 'HarmonyWidget',
    dynamic: false,
};

const circles: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/wallArch.png`,
    cssTheme: 'circles.scss',
    plasmaColor: 'Circles.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    kvantumTheme: 'a-circles',
    qtIconTheme: 'Vivid-Dark-Icons',
    gtkTheme: 'Nordic-darker-standard-buttons',
    gtkIconTheme: 'Vivid-Dark-Icons',
    themeMode: 'dark',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(61AFEFff) rgba(7EC7A2ff) 0deg',
        inactiveBorder: 'rgba(00000000) 0deg',
        rounding: 10,
        dropShadow: 'no',
        kitty: 'circles.conf',
        konsole: 'Circles',
    },
    desktopWidget: 'CirclesWidget',
    dynamic: false,
};

const whiteFlower: ThemeDefinition = {
    wallpaper: `${WALLPAPER_PATH}/white-flower.jpg`,
    cssTheme: 'white-flower.scss',
    plasmaColor: 'MateriaYaruLight.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    qtIconTheme: 'Rowaita-Pink-Light',
    kvantumTheme: 'Mkos-BigSur-Transparent',
    gtkTheme: 'Jasper-Light-Dracula',
    gtkIconTheme: 'Rowaita-Pink-Light',
    themeMode: 'light',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 8,
        dropShadow: 'no',
        kitty: 'whiteFlower.conf',
        konsole: 'light',
    },
    desktopWidget: 'WhiteFlower',
    dynamic: false,
};

const dynamicM3Dark: ThemeDefinition = {
    wallpaperPath: settings.theme.darkM3WallpaperPath,
    dynamic: true,
    interval: 15 * 60 * 1000,
    themeMode: 'dark',
    cssTheme: 'm3.scss', // Add cssTheme for dynamic themes, if needed - placeholder name
    plasmaColor: 'MateriaYaruDark.colors',
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    kvantumTheme: 'Win10XOS-Concept',
    gtkTheme: 'Breeze-Dark',
    qtIconTheme: 'BeautySolar',
    gtkIconTheme: 'BeautySolar',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 17,
        dropShadow: 'no',
        kitty: 'material-you.conf', // Reused 'material-you.conf' - verify if this is correct
        konsole: 'MaterialYouAlt',
    },
    desktopWidget: 'BHWidget', // Reused 'BHWidget' - verify if this is correct
};

const dynamicM3Light: ThemeDefinition = {
    wallpaperPath: settings.theme.lightM3WallpaperPath,
    dynamic: true,
    interval: 15 * 60 * 1000,
    themeMode: 'light',
    cssTheme: 'm3.scss', // Add cssTheme for dynamic themes, if needed - placeholder name
    plasmaColor: 'MateriaYaruDark.colors', // Note: Using 'MateriaYaruDark.colors' for light too - verify if this is intended
    qt5styleTheme: 'Breeze',
    qt6styleTheme: 'kvantum',
    kvantumTheme: 'Arc',
    gtkTheme: 'Breeze',
    qtIconTheme: 'BeautySolar',
    gtkIconTheme: 'BeautySolar',
    fontName: 'JF Flat 11',
    hypr: {
        borderWidth: 2,
        activeBorder: 'rgba(678382ff) rgba(9d6c73ff) 0deg',
        inactiveBorder: 'rgba(59595900) 0deg',
        rounding: 17,
        dropShadow: 'no',
        kitty: 'material-you.conf', // Reused 'material-you.conf' - verify if this is correct
        konsole: 'MaterialYouAlt',
    },
    desktopWidget: 'BHWidget', // Reused 'BHWidget' - verify if this is correct
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

const ThemesDictionary: { [key: number]: ThemeDefinition } = {
    [BLACK_HOLE_THEME]: blackHole,
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

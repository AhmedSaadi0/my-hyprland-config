
const BLACK_HOLE_THEME = 0;
const DEER_THEME = 1;

const QT_FILE_PATH = '~/.config/qt5ct/qt5ct.conf';
const PLASMA_COLOR_CHANGER = '~/.config/ags/modules/theme/bin/plasma-theme';
const PLASMA_COLORS_PATH = '~/.config/ags/modules/theme/plasma-colors/';

const black_hole = {
    id: BLACK_HOLE_THEME,
    wallpaper: ".config/hypr/wallpapers/black-hole.png",
    css_theme: "black-hole.scss",
    plasma_color: "ArcMidnightDark.colors",
    qt_style_theme: "Lightly",
    qt_icon_theme: "NeonIcons",
    kvantum_theme: "a-color",
    gtk_theme: "Shades-of-purple",
}

const deer = {
    id: DEER_THEME,
    wallpaper: ".config/hypr/wallpapers/deer.jpg",
    css_theme: "deer.scss",
    plasma_color: "BlueDeer.colors",
    qt_style_theme: "Lightly",
    qt_icon_theme: "NeonIcons",
    kvantum_theme: "a-color",
    gtk_theme: "Shades-of-purple",
}

const Themes = {
    BLACK_HOLE_THEME: black_hole,
    DEER_THEME: deer,
}
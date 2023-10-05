const { Service } = ags;
const { exec, execAsync } = ags.Utils;
import Themes from "./themes.js";
import { BLACK_HOLE_THEME, DEER_THEME } from "./themes.js";


class ThemeService extends Service {
    static {
        Service.register(this,
            {
                'selected-theme': []
            }
        );
    }

    qtFilePath = '/home/ahmed/.config/qt5ct/qt5ct.conf';
    plasmaColorChanger = ags.App.configDir + '/modules/theme/bin/plasma-theme';
    plasmaColorsPath = ags.App.configDir + '/modules/theme/plasma-colors/';
    selectedTheme = BLACK_HOLE_THEME;

    constructor() {
        super();
        exec('swww init');
        this.changeTheme(this.selectedTheme);
    }

    changeTheme(selectedTheme) {
        let theme = Themes[selectedTheme];
        this.selectedTheme = selectedTheme;

        this.changeCss(theme.css_theme);
        this.changeWallpaper(theme.wallpaper);
        this.changePlasmaColor(theme.plasma_color);
        this.changeQtStyle(theme.qt_style_theme);
        this.changeIcons(theme.qt_icon_theme);
        this.changeKvantumTheme(theme.kvantum_theme);
    }

    changeWallpaper(wallpaper) {
        execAsync([
            'swww',
            'img',
            '--transition-type',
            'grow',
            '--transition-pos',
            exec('hyprctl cursorpos').replace(' ', ''),
            wallpaper,
        ]).catch(print);
    }

    changeCss(cssTheme) {
        const scss = ags.App.configDir + '/scss/main.scss';
        const css = ags.App.configDir + '/style.css';

        // const sedCommand = `sed -i "1s/^.*$/@import '\\''${cssTheme}.scss'\\'';/" ${scss}`;
        // const sedCommand = `sed -i "1s/.*/This is the new first line/" ${scss}`;
        const newTh = `@import './themes/${cssTheme}';`;

        execAsync([
            "sed",
            "-i",
            `1s|.*|${newTh}|`,
            scss
        ]).then(() => {
            exec(`sassc ${scss} ${css}`);
            ags.App.resetCss();
            ags.App.applyCss(css);
        }).catch(print)
    }

    changePlasmaColor(plasmaColor) {
        execAsync([
            this.plasmaColorChanger,
            '-c',
            this.plasmaColorsPath + plasmaColor
        ]).catch(print);
    }

    changeQtStyle(qtStyle) {
        execAsync([
            'sed',
            '-i',
            `s/style=.*/style=${qtStyle}/g`,
            this.qtFilePath,
        ]).catch(print);
    }

    changeIcons(icons) {
        execAsync([
            'sed',
            '-i',
            `s/icon_theme=.*/icon_theme=${icons}/g`,
            this.qtFilePath,
        ]).catch(print);
    }

    changeKvantumTheme(kvantumTheme) {
        execAsync([
            'kvantummanager',
            '--set',
            kvantumTheme,
        ]).catch(print);
    }

}


// the singleton instance
const theme = new ThemeService();

// export to use in other modules
export default theme;
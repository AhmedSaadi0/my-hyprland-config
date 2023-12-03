import ThemesDictionary, { WIN_20, UNICAT_THEME } from "../theme/themes.js";
import { timeout, USER, exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import App from "resource:///com/github/Aylur/ags/app.js";
import Service from 'resource:///com/github/Aylur/ags/service.js';
import prayerService from "./PrayerTimesService.js";

class ThemeService extends Service {
    static {
        Service.register(this,
            {
                'selected-theme': []
            }
        );
    }

    qtFilePath = `/home/${USER}/.config/qt5ct/qt5ct.conf`;
    plasmaColorChanger = App.configDir + '/modules/theme/bin/plasma-theme';
    plasmaColorsPath = App.configDir + '/modules/theme/plasma-colors/';
    selectedTheme = UNICAT_THEME;
    rofiFilePath = `/home/${USER}/.config/rofi/config.rasi`;

    constructor() {
        super();
        exec('swww init');
        this.changeTheme(this.selectedTheme);
    }

    changeTheme(selectedTheme) {
        let theme = ThemesDictionary[selectedTheme];

        this.changeCss(theme.css_theme);
        this.changeWallpaper(theme.wallpaper);
        this.changePlasmaColor(theme.plasma_color);

        this.changeGTKTheme(theme.gtk_theme, theme.gtk_mode, theme.gtk_icon_theme);

        this.changeQtStyle(theme.qt_style_theme);
        this.changeIcons(theme.qt_icon_theme);
        // this.changeKvantumTheme(theme.kvantum_theme);
        // this.changeRofiTheme(theme.rofi_theme);
        this.showDesktopWidget(theme.desktop_widget);

        let hypr = theme.hypr;
        this.steHyprland(
            hypr.border_width,
            hypr.active_border,
            hypr.inactive_border,
            hypr.rounding,
            hypr.drop_shadow,
            hypr.kitty,
            hypr.konsole,
        )

        this.selectedTheme = selectedTheme;
        this.emit("changed");
        prayerService.emit("changed");
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
        const scss = App.configDir + '/scss/main.scss';
        const css = App.configDir + '/style.css';

        const newTh = `@import './themes/${cssTheme}';`;

        execAsync([
            "sed",
            "-i",
            `1s|.*|${newTh}|`,
            scss
        ]).then(() => {
            exec(`sassc ${scss} ${css}`);
            App.resetCss();
            App.applyCss(css);
        }).catch(print)
    }

    changePlasmaColor(plasmaColor) {
        const plasmaCmd = `plasma-apply-colorscheme`;
        execAsync([
            plasmaCmd,
            plasmaColor.split('.')[0]
        ]).catch(print);
        // execAsync([
        //     this.plasmaColorChanger,
        //     '-c',
        //     this.plasmaColorsPath + plasmaColor
        // ]).catch(print);
    }

    changeGTKTheme(GTKTheme, gtkMode, iconTheme) {

        execAsync([
            `gsettings`,
            `set`,
            `org.gnome.desktop.interface`,
            `color-scheme`,
            `prefer-${gtkMode}`
        ]).catch(print);


        execAsync([
            `gsettings`,
            `set`,
            `org.gnome.desktop.interface`,
            `gtk-theme`,
            `Adwaita`
        ]).catch(print);

        execAsync([
            `gsettings`,
            `set`,
            `org.gnome.desktop.wm.preferences`,
            `theme`,
            `Adwaita`
        ]).catch(print);

        setTimeout(() => {
            execAsync([
                `gsettings`,
                `set`,
                `org.gnome.desktop.interface`,
                `gtk-theme`,
                GTKTheme
            ]).catch(print);

            execAsync([
                `gsettings`,
                `set`,
                `org.gnome.desktop.wm.preferences`,
                `theme`,
                GTKTheme
            ]).catch(print);

        }, 2000);

        execAsync([
            `gsettings`,
            `set`,
            `org.gnome.desktop.interface`,
            `icon-theme`,
            iconTheme
        ]).catch(print);
    }

    steHyprland(
        border_width,
        active_border,
        inactive_border,
        rounding,
        drop_shadow,
        kittyConfig,
        konsoleTheme,
    ) {

        const kittyBind = `bind = $mainMod, Return, exec, kitty -c ${App.configDir}/modules/theme/kitty/${kittyConfig}`;
        const konsoleBind = `bind = $mainMod, Return, exec, konsole --profile ${konsoleTheme}`;

        execAsync([
            "sed",
            "-i",
            `42s|.*|${kittyBind}|`,
            `/home/${USER}/.config/hypr/binding.conf`
        ]).then(() => {
            timeout(1000, () => {
                execAsync(`hyprctl keyword general:border_size ${border_width}`);
                execAsync(`hyprctl keyword general:col.active_border ${active_border}`);
                execAsync(`hyprctl keyword general:col.inactive_border ${inactive_border}`);
                execAsync(`hyprctl keyword decoration:drop_shadow ${drop_shadow ? 'yes' : 'no'}`);
                execAsync(`hyprctl keyword decoration:rounding ${rounding}`);
                // execAsync(`hyprctl setcursor material_light_cursors 24 `);
            });
        }).catch(print)
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

    changeRofiTheme(rofiTheme) {
        const newTheme = `@import "${App.configDir}/modules/theme/rofi/${rofiTheme}"`;
        execAsync([
            "sed",
            "-i",
            `11s|.*|${newTheme}|`,
            this.rofiFilePath
        ]).catch(print);
    }

    changeKvantumTheme(kvantumTheme) {
        execAsync([
            'kvantummanager',
            '--set',
            kvantumTheme,
        ]).catch(print);
    }

    showDesktopWidget(widget) {
        let oldTheme = ThemesDictionary[this.selectedTheme];
        if (oldTheme.desktop_widget !== widget && oldTheme.desktop_widget !== null) {
            this.hideWidget(oldTheme.desktop_widget);
        }
        if (widget !== null) {
            timeout(1000, () => {
                this.showWidget(widget);
            });
        }
    }

    hideWidget(functionName) {
        execAsync([
            "ags",
            "-r",
            `Hide${functionName}()`
        ]).catch(print);
    }

    showWidget(functionName) {
        execAsync([
            "ags",
            "-r",
            `Show${functionName}()`
        ]).catch(print);
    }

}


// the singleton instance
const themeService = new ThemeService();

// export to use in other modules
export default themeService;
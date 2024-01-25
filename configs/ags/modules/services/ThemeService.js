import ThemesDictionary, { WIN_20, UNICAT_THEME } from "../theme/themes.js";
import { timeout, USER, exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import App from "resource:///com/github/Aylur/ags/app.js";
import Service from 'resource:///com/github/Aylur/ags/service.js';
import prayerService from "./PrayerTimesService.js";
import { Utils } from "../utils/imports.js";
import settings from "../settings.js";

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
    wallpapers_list = [];

    CACHE_FILE_PATH = `/home/${USER}/.cache/ahmed-hyprland-conf.temp`
    wallpaperIntervalId
    selectedLightWallpaper = 0;
    selectedDarkWallpaper = 0;

    constructor() {
        super();
        exec('swww init');

        this.getCachedVariables();
        this.changeTheme(this.selectedTheme);
    }

    changeTheme(selectedTheme) {
        let theme = ThemesDictionary[selectedTheme];

        if (this.wallpaperIntervalId) {
            clearInterval(this.wallpaperIntervalId);
        }

        if (theme.dynamic) {
            this.setDynamicWallpapers(theme.wallpaper_path, theme.gtk_mode);
        } else {
            this.changeCss(theme.css_theme);
            this.changeWallpaper(theme.wallpaper);
        }

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

        this.cacheVariables();
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
        // const scss = App.configDir + '/scss/main.scss';
        const scss = settings.theme.mainCss;
        // const css = App.configDir + '/style.css';
        const css = settings.theme.styleCss;

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

    setDynamicWallpapers(path, themeMode) {
        Utils.execAsync([settings.scripts.get_wallpapers, path])
            .then(out => {

                const wallpapers = JSON.parse(out);
                this.wallpapers_list = wallpapers

                // First call
                this.callNewRandomWallpaper(themeMode);

                // Loop on wallpapers
                this.wallpaperIntervalId = setInterval(() => {
                    this.callNewRandomWallpaper(themeMode);
                }, 5 * 60 * 1000);
            })
            .catch(err => print(err));
    }

    callNewRandomWallpaper(themeMode) {
        // const randomIndex = Math.floor(Math.random() * this.wallpapers_list.length);
        let selectedWallpaperIndex = 0;

        if (themeMode == "dark") {
            selectedWallpaperIndex = this.selectedDarkWallpaper;
            this.selectedDarkWallpaper = (this.selectedDarkWallpaper + 1) % this.wallpapers_list.length;
        } else {
            selectedWallpaperIndex = this.selectedLightWallpaper;
            this.selectedLightWallpaper = (this.selectedLightWallpaper + 1) % this.wallpapers_list.length;
        }

        const wallpaper = this.wallpapers_list[selectedWallpaperIndex];

        this.changeWallpaper(wallpaper);
        this.createM3ColorSchema(wallpaper, themeMode);
        this.cacheVariables();
    }

    createM3ColorSchema(wallpaper, mode) {
        execAsync([
            "python",
            settings.scripts.dynamicM3Py,
            wallpaper,
            "-m",
            mode
        ]).then(() => {
            this.changeCss("m3/dynamic.scss");
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

    cacheVariables() {
        const newData = {
            "selected_theme": this.selectedTheme,
            "selected_dark_wallpaper": this.selectedDarkWallpaper,
            "selected_light_wallpaper": this.selectedLightWallpaper,
        }
        Utils.writeFile(JSON.stringify(newData, null, 2), this.CACHE_FILE_PATH).catch(err => print(err))
    }

    getCachedVariables() {
        try {
            const cachedData = JSON.parse(Utils.readFile(this.CACHE_FILE_PATH));
            this.selectedTheme = cachedData.selected_theme
            this.selectedDarkWallpaper = cachedData.selected_dark_wallpaper;
            this.selectedLightWallpaper = cachedData.selected_light_wallpaper;

            if (!this.selectedTheme) {
                this.selectedTheme = UNICAT_THEME
            }
        } catch (TypeError) {
            this.cacheVariables();
        }
    }

}


// the singleton instance
const themeService = new ThemeService();

// export to use in other modules
export default themeService;
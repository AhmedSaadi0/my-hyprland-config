import ThemesDictionary, { UNICAT_THEME } from '../theme/themes.js';
import { USER } from 'resource:///com/github/Aylur/ags/utils.js';
import prayerService from './PrayerTimesService.js';
import settings from '../settings.js';

class ThemeService extends Service {
    static {
        Service.register(
            this,
            {},
            {
                dynamicWallpaperIsOn: ['boolean', 'r'],
                isDynamicTheme: ['boolean', 'r'],
            }
        );
    }

    qt5FilePath = `/home/${USER}/.config/qt5ct/qt5ct.conf`;
    qt6FilePath = `/home/${USER}/.config/qt6ct/qt6ct.conf`;
    plasmaColorChanger = App.configDir + '/modules/theme/bin/plasma-theme';
    plasmaColorsPath = App.configDir + '/modules/theme/plasma-colors/';
    selectedTheme = UNICAT_THEME;
    rofiFilePath = `/home/${USER}/.config/rofi/config.rasi`;
    wallpapersList = [];

    CACHE_FILE_PATH = `/home/${USER}/.cache/ahmed-hyprland-conf.temp`;
    wallpaperIntervalId;
    selectedLightWallpaper = 0;
    selectedDarkWallpaper = 0;
    dynamicWallpaperStatus = true;
    showDesktopWidgetStatus = true;

    constructor() {
        super();
        console.log('Starting theme service');
        Utils.exec('swww-daemon');

        this.getCachedVariables();
    }

    changeTheme(selectedTheme) {
        let theme = ThemesDictionary[selectedTheme];

        this.clearDynamicWallpaperInterval();

        if (theme.dynamic) {
            this.setDynamicWallpapers(
                theme.wallpaper_path,
                theme.gtk_mode,
                theme.interval
            );
        } else {
            this.changeCss(theme.css_theme);
            this.changeWallpaper(theme.wallpaper);
        }

        if (settings.changePlasmaColor) {
            this.changePlasmaColor(theme.plasma_color);
            this.changePlasmaIcons(theme.qt_icon_theme);
        }
        this.changeKonsoleProfile(theme.hypr.konsole);

        this.changeGTKTheme(
            theme.gtk_theme,
            theme.gtk_mode,
            theme.gtk_icon_theme,
            theme.font_name
        );
        if (!theme.dynamic) {
            this.changeGtk4Theme(
                theme.wallpaper,
                'ahmed-config-gtk-theme',
                theme.gtk_mode
            );
        }

        this.changeQtStyle(theme.qt_5_style_theme, theme.qt_6_style_theme);
        this.changeIcons(theme.qt_icon_theme);
        this.changeKvantumTheme(theme.kvantum_theme);

        if (this.showDesktopWidgetStatus) {
            this.showDesktopWidget(theme.desktop_widget);
        }

        let hypr = theme.hypr;
        this.setHyprland(
            hypr.border_width,
            hypr.active_border,
            hypr.inactive_border,
            hypr.rounding,
            hypr.drop_shadow
            // hypr.kitty
        );

        this.selectedTheme = selectedTheme;
        this.emit('changed');
        prayerService.emit('changed');

        this.cacheVariables();
    }

    changeWallpaper(wallpaper) {
        Utils.execAsync([
            'swww',
            'img',
            '--transition-type',
            // 'grow',
            'random',
            // '--transition-pos',
            // Utils.exec('hyprctl cursorpos').replace(' ', ''),
            wallpaper,
        ]).catch(print);
    }

    changeCss(cssTheme) {
        // const scss = App.configDir + '/scss/main.scss';
        const scss = settings.theme.mainCss;
        // const css = App.configDir + '/style.css';
        const css = settings.theme.styleCss;

        const newTh = `@import './themes/${cssTheme}';`;

        Utils.execAsync(['sed', '-i', `1s|.*|${newTh}|`, scss])
            .then(() => {
                Utils.exec(`sassc ${scss} ${css}`);
                App.resetCss();
                App.applyCss(css);
            })
            .catch(print);
    }

    get dynamicWallpaperIsOn() {
        return this.dynamicWallpaperStatus;
    }

    get isDynamicTheme() {
        return ThemesDictionary[this.selectedTheme].dynamic;
    }

    setDynamicWallpapers(path, themeMode, interval) {
        Utils.execAsync([settings.scripts.get_wallpapers, path])
            .then((out) => {
                const wallpapers = JSON.parse(out);
                this.wallpapersList = wallpapers;

                // First call
                this.callNextWallpaper(themeMode);

                // Loop on wallpapers
                if (this.dynamicWallpaperIsOn) {
                    this.wallpaperIntervalId = setInterval(() => {
                        this.callNextWallpaper(themeMode);
                    }, interval);
                } else {
                    this.clearDynamicWallpaperInterval();
                }
            })
            .catch((err) => print(err));
    }

    toggleDynamicWallpaper() {
        if (this.isDynamicTheme && this.dynamicWallpaperIsOn)
            this.stopDynamicWallpaper();
        else this.startDynamicWallpaper();
    }

    clearDynamicWallpaperInterval() {
        if (this.wallpaperIntervalId) {
            clearInterval(this.wallpaperIntervalId);
        }
    }

    stopDynamicWallpaper() {
        this.dynamicWallpaperStatus = false;
        this.clearDynamicWallpaperInterval();
        this.cacheVariables();
        this.emit('changed');
    }

    startDynamicWallpaper() {
        let theme = ThemesDictionary[this.selectedTheme];
        this.dynamicWallpaperStatus = true;
        if (this.wallpaperIntervalId) {
            clearInterval(this.wallpaperIntervalId);
        }
        this.setDynamicWallpapers(
            theme.wallpaper_path,
            theme.gtk_mode,
            theme.interval
        );
        this.cacheVariables();
        this.emit('changed');
    }

    callNextWallpaper(themeMode) {
        // const randomIndex = Math.floor(Math.random() * this.wallpapers_list.length);
        let selectedWallpaperIndex = 0;

        if (themeMode == 'dark') {
            selectedWallpaperIndex = this.selectedDarkWallpaper;
            if (this.dynamicWallpaperIsOn)
                this.selectedDarkWallpaper =
                    (this.selectedDarkWallpaper + 1) %
                    this.wallpapersList.length;
        } else {
            selectedWallpaperIndex = this.selectedLightWallpaper;
            if (this.dynamicWallpaperIsOn)
                this.selectedLightWallpaper =
                    (this.selectedLightWallpaper + 1) %
                    this.wallpapersList.length;
        }

        const wallpaper = this.wallpapersList[selectedWallpaperIndex];

        this.changeWallpaper(wallpaper);
        this.createM3ColorSchema(wallpaper, themeMode);
        this.cacheVariables();
    }

    createM3ColorSchema(wallpaper, mode) {
        Utils.execAsync([
            'python',
            settings.scripts.dynamicM3Py,
            wallpaper,
            '-m',
            mode,
        ])
            .then(() => {
                this.changeCss('m3/dynamic.scss');
            })
            .catch(print);
    }

    changePlasmaColor(plasmaColor) {
        const plasmaCmd = `plasma-apply-colorscheme`;
        Utils.execAsync([plasmaCmd, plasmaColor.split('.')[0]]).catch(print);
    }

    changePlasmaIcons(plasmaIcons) {
        Utils.execAsync([
            'kwriteconfig5',
            '--file',
            `/home/${USER}/.config/kdeglobals`,
            '--group',
            'Icons',
            '--key',
            'Theme',
            plasmaIcons,
        ]);
    }

    changeGTKTheme(GTKTheme, gtkMode, iconTheme, fontName) {
        // Utils.execAsync([
        //     `gsettings`,
        //     `set`,
        //     `org.gnome.desktop.interface`,
        //     `color-scheme`,
        //     `prefer-${gtkMode}`,
        // ]).catch(print);
        //
        // Utils.execAsync([
        //     `gsettings`,
        //     `set`,
        //     `org.gnome.desktop.interface`,
        //     `gtk-theme`,
        //     `Adwaita`,
        // ]).catch(print);

        setTimeout(() => {
            Utils.execAsync([
                `gsettings`,
                `set`,
                `org.gnome.desktop.interface`,
                `gtk-theme`,
                GTKTheme,
            ]).catch(print);

            Utils.execAsync([
                `gsettings`,
                `set`,
                `org.gnome.desktop.wm.preferences`,
                `theme`,
                GTKTheme,
            ]).catch(print);
        }, 2000);

        Utils.execAsync([
            `gsettings`,
            `set`,
            `org.gnome.desktop.interface`,
            `icon-theme`,
            iconTheme,
        ]).catch(print);

        Utils.execAsync([
            `gsettings`,
            `set`,
            `org.gnome.desktop.interface`,
            `font-name`,
            fontName,
        ]).catch(print);
    }

    changeGtk4Theme(wallpaperPath, themeName, themeMode) {
        Utils.execAsync([
            'python',
            settings.scripts.gtk_theme,
            '-p',
            wallpaperPath,
            '-n',
            themeName,
            '-m',
            themeMode,
            '-t',
            '20',
        ]).catch(print);
    }

    setHyprland(
        border_width,
        active_border,
        inactive_border,
        rounding,
        drop_shadow
        // kittyConfig
        // konsoleTheme
    ) {
        // const kittyBind = `bind = $mainMod, Return, Utils.exec, kitty -c ${App.configDir}/modules/theme/kitty/${kittyConfig}`;
        // const konsoleBind = `bind = $mainMod, Return, Utils.exec, konsole --profile ${konsoleTheme}`;
        Utils.timeout(500, () => {
            Utils.execAsync(
                `hyprctl keyword general:border_size ${border_width}`
            );
            Utils.execAsync(
                `hyprctl keyword general:col.active_border ${active_border}`
            );
            Utils.execAsync(
                `hyprctl keyword general:col.inactive_border ${inactive_border}`
            );
            Utils.execAsync(
                `hyprctl keyword decoration:drop_shadow ${drop_shadow ? 'yes' : 'no'}`
            );
            Utils.execAsync(`hyprctl keyword decoration:rounding ${rounding}`);
            // Utils.execAsync(`hyprctl setcursor Bibata-Rainbow-Modern 24 `);
        });
    }

    changeKonsoleProfile(konsoleProfile) {
        const konsoleProfileData = `[Desktop Entry]
DefaultProfile=${konsoleProfile}.profile

[General]
ConfigVersion=1

[MainWindow]
ToolBarsMovable=Disabled
`;

        Utils.writeFile(konsoleProfileData, `/home/${USER}/.config/konsolerc`)
            // .then((file) => print('file is the Gio.File'))
            .catch((err) => print(err));
    }

    changeQtStyle(qt5Style, qt6Style) {
        Utils.execAsync([
            'sed',
            '-i',
            `s/style=.*/style=${qt5Style}/g`,
            this.qt5FilePath,
        ]).catch(print);

        Utils.execAsync([
            'sed',
            '-i',
            `s/style=.*/style=${qt6Style}/g`,
            this.qt6FilePath,
        ]).catch(print);
    }

    changeIcons(icons) {
        Utils.execAsync([
            'sed',
            '-i',
            `s/icon_theme=.*/icon_theme=${icons}/g`,
            this.qt5FilePath,
        ]).catch(print);

        Utils.execAsync([
            'sed',
            '-i',
            `s/icon_theme=.*/icon_theme=${icons}/g`,
            this.qt6FilePath,
        ]).catch(print);
    }

    changeRofiTheme(rofiTheme) {
        const newTheme = `@import "${App.configDir}/modules/theme/rofi/${rofiTheme}"`;
        Utils.execAsync([
            'sed',
            '-i',
            `11s|.*|${newTheme}|`,
            this.rofiFilePath,
        ]).catch(print);
    }

    changeKvantumTheme(kvantumTheme) {
        Utils.execAsync(['kvantummanager', '--set', kvantumTheme]).catch(print);
    }

    showDesktopWidget(widget) {
        let oldTheme = ThemesDictionary[this.selectedTheme];
        if (
            oldTheme.desktop_widget !== widget &&
            oldTheme.desktop_widget !== null
        ) {
            this.hideWidget(oldTheme.desktop_widget);
        }
        if (widget !== null) {
            Utils.timeout(1000, () => {
                this.showWidget(widget);
            });
        }
    }

    hideWidget(functionName) {
        Utils.execAsync(['ags', '-r', `Hide${functionName}()`]).catch(print);
    }

    showWidget(functionName) {
        Utils.execAsync(['ags', '-r', `Show${functionName}()`]).catch(print);
    }

    cacheVariables() {
        const newData = {
            selected_theme: this.selectedTheme,
            selected_dark_wallpaper: this.selectedDarkWallpaper,
            selected_light_wallpaper: this.selectedLightWallpaper,
            dynamic_wallpaper_status: this.dynamicWallpaperStatus,
            show_desktop_widget: this.showDesktopWidgetStatus,
        };
        Utils.writeFile(
            JSON.stringify(newData, null, 2),
            this.CACHE_FILE_PATH
        ).catch((err) => print(err));
    }

    getCachedVariables() {
        try {
            const cachedData = JSON.parse(Utils.readFile(this.CACHE_FILE_PATH));
            this.selectedTheme = cachedData.selected_theme;
            this.selectedDarkWallpaper = cachedData.selected_dark_wallpaper;
            this.selectedLightWallpaper = cachedData.selected_light_wallpaper;
            this.dynamicWallpaperStatus = cachedData.dynamic_wallpaper_status;
            this.showDesktopWidgetStatus = cachedData.show_desktop_widget;

            if (!this.selectedTheme && this.selectedTheme !== 0) {
                this.selectedTheme = UNICAT_THEME;
            }
        } catch (TypeError) {
            this.cacheVariables();
        }
        this.changeTheme(this.selectedTheme);
    }
}

// the singleton instance
const themeService = new ThemeService();

// export to use in other modules
export default themeService;

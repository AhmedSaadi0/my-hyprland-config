import { exec, execAsync } from 'astal/process';
import ThemesDictionary, { COLOR_THEME } from './themes';
import type { Subscribable } from 'astal/binding';
import { readFileAsync, Variable, writeFileAsync } from 'astal';
import settings from './settings';
import app from 'astal/gtk3/app';

interface CacheData {
    selectedTheme: number;
    selectedDarkWallpaper: number;
    selectedLightWallpaper: number;
    dynamicWallpaperStatus: boolean;
    showDesktopWidget: boolean;
}

class ThemeManager {
    private selectedTheme: Subscribable<number>;
    private wallpapersList: string[] = [];
    // private wallpaperIntervalId: Timer | null = null;
    private selectedLightWallpaper = Variable<number>(0);
    private selectedDarkWallpaper = Variable<number>(0);
    private dynamicWallpaperStatus = Variable<boolean>(true);
    private showDesktopWidgetStatus = Variable<boolean>(true);

    getSelectedTheme(): Subscribable<number> {
        print('Changed');
        return this.selectedTheme;
    }

    constructor() {
        print('Starting theme service');
        this.selectedTheme = Variable(COLOR_THEME);

        this.loadCachedVariables();
        this.applyCachedTheme();
    }

    get dynamicWallpaperIsOn(): Subscribable<boolean> {
        return this.dynamicWallpaperStatus;
    }

    get isDynamicTheme(): Subscribable<boolean> {
        // TODO:
        return Variable(false);
    }

    changeTheme(selectedTheme: number) {
        const theme = ThemesDictionary[selectedTheme];

        if (!theme) {
            console.warn(`Theme '${selectedTheme}' not found`);
            return;
        }

        this.clearDynamicWallpaperInterval();

        if (theme.dynamic && theme.wallpaperPath && theme.interval) {
            this.setDynamicWallpapers(
                theme.wallpaperPath,
                theme.gtkMode,
                theme.interval
            );
        } else {
            this.changeCss(theme.cssTheme);
            if (theme.wallpaper) this.changeWallpaper(theme.wallpaper);
        }

        // Additional theme application logic
        this.changePlasmaColor(theme.plasmaColor);
        this.changePlasmaIcons(theme.qtIconTheme);
        this.changeKonsoleProfile(theme.hypr.konsole);
        this.changeGtkTheme(
            theme.gtkTheme,
            theme.gtkMode,
            theme.qtIconTheme,
            theme.fontName
        );
        this.changeKvantumTheme(theme.kvantumTheme);
        this.setHyprland(
            theme.hypr.borderWidth,
            theme.hypr.activeBorder,
            theme.hypr.inactiveBorder,
            theme.hypr.rounding
        );

        if (this.showDesktopWidgetStatus.get()) {
            this.showDesktopWidget(theme.desktopWidget);
        }

        this.selectedTheme.set(selectedTheme);
        this.cacheVariables();
    }

    private changeWallpaper(wallpaper: string) {
        print('Changing wallpaper');
        execAsync([
            'swww',
            'img',
            '--transition-type',
            'random',
            wallpaper,
        ]).catch(print);
    }

    private changeCss(cssTheme: string) {
        print('Changing CSS');
        const scss = settings.theme.mainCss;
        const css = settings.theme.styleCss;

        const newTh = `@import './themes/${cssTheme}';`;

        execAsync(['sed', '-i', `1s|.*|${newTh}|`, scss])
            .then(() => {
                exec(`sassc ${scss} ${css}`);
                app.apply_css(css, true);
            })
            .catch(print);
    }

    private setDynamicWallpapers(
        path: string,
        themeMode: string,
        interval: number
    ) {
        execAsync([settings.scripts.getWallpapers, path]).then((result) => {
            this.wallpapersList = JSON.parse(result);
            this.callNextWallpaper(themeMode);

            if (this.dynamicWallpaperStatus.get()) {
                // this.wallpaperIntervalId = Timer.repeat(interval, () =>
                //     this.callNextWallpaper(themeMode)
                // );
            }
        });
    }

    private callNextWallpaper(themeMode: string) {
        print('Calling next wallpaper');
        let selectedIndex = 0;

        if (themeMode === 'dark') {
            selectedIndex = this.selectedDarkWallpaper.get();
            if (this.dynamicWallpaperStatus.get()) {
                this.selectedDarkWallpaper.set(
                    (selectedIndex + 1) % this.wallpapersList.length
                );
            }
        } else {
            selectedIndex = this.selectedLightWallpaper.get();
            if (this.dynamicWallpaperStatus.get()) {
                this.selectedLightWallpaper.set(
                    (selectedIndex + 1) % this.wallpapersList.length
                );
            }
        }

        const wallpaper = this.wallpapersList[selectedIndex];
        if (wallpaper) {
            this.changeWallpaper(wallpaper);
            this.createM3ColorSchema(wallpaper, themeMode);
            this.cacheVariables();
        }
    }

    private async createM3ColorSchema(
        wallpaper: string,
        mode: string
    ): Promise<void> {
        print('Creating M3 color schema');
        // Implement color schema creation
    }

    private changePlasmaColor(plasmaColor: string) {
        print('Changing plasma color');
        execAsync([
            'plasma-apply-colorscheme',
            plasmaColor.split('.')[0],
        ]).catch(print);
    }

    private changePlasmaIcons(plasmaIcons: string) {
        print('Changing plasma icons ' + plasmaIcons);
        execAsync([
            'kwriteconfig5',
            '--file',
            `${settings.homePath}/.config/kdeglobals`,
            '--group',
            'Icons',
            '--key',
            'Theme',
            plasmaIcons,
        ]).catch(print);
    }

    private changeGtkTheme(
        gtkTheme: string,
        gtkMode: string,
        iconTheme: string,
        fontName: string
    ) {
        print('Changing GTK theme');
        // Implement GTK theme changes
    }

    private setHyprland(
        borderWidth: number,
        activeBorder: string,
        inactiveBorder: string,
        rounding: number
    ) {
        // TODO: -> use built in hyprland lib
        print('Setting Hyprland config');
        execAsync([
            'hyprctl',
            'keyword',
            'general:border_size',
            borderWidth.toString(),
        ]);
        execAsync([
            'hyprctl',
            'keyword',
            'general:col.active_border',
            activeBorder,
        ]);
        execAsync([
            'hyprctl',
            'keyword',
            'general:col.inactive_border',
            inactiveBorder,
        ]);
        exec([
            'hyprctl',
            'keyword',
            'decoration:rounding',
            rounding.toString(),
        ]);
    }

    private changeKonsoleProfile(profile: string) {
        print('Changing Konsole profile');
        const configData = `[Desktop Entry]
DefaultProfile=${profile}.profile

[General]
ConfigVersion=1

[MainWindow]
ToolBarsMovable=Disabled
`;

        writeFileAsync(
            `${settings.homePath}/.config/konsolerc`,
            configData
        ).catch(print);
    }

    private changeKvantumTheme(theme: string) {
        print('Changing Kvantum theme');
        execAsync(['kvantummanager', '--set', theme]).catch(print);
    }

    private showDesktopWidget(widget: string | null): void {
        print('Showing desktop widget');
        // Implement widget showing logic
    }

    private clearDynamicWallpaperInterval(): void {
        // if (this.wallpaperIntervalId) {
        //     this.wallpaperIntervalId.stop();
        //     this.wallpaperIntervalId = null;
        // }
    }

    private cacheVariables() {
        const data: CacheData = {
            selectedTheme: this.selectedTheme.get(),
            selectedDarkWallpaper: this.selectedDarkWallpaper.get(),
            selectedLightWallpaper: this.selectedLightWallpaper.get(),
            dynamicWallpaperStatus: this.dynamicWallpaperStatus.get(),
            showDesktopWidget: this.showDesktopWidgetStatus.get(),
        };

        writeFileAsync(
            settings.cacheFilePath,
            JSON.stringify(data, null, 2)
        ).catch(print);
    }

    private loadCachedVariables() {
        readFileAsync(settings.cacheFilePath).then((data) => {
            const cached = JSON.parse(data) as CacheData;

            this.selectedTheme.set(cached.selectedTheme ?? COLOR_THEME);
            this.selectedDarkWallpaper.set(cached.selectedDarkWallpaper ?? 0);
            this.selectedLightWallpaper.set(cached.selectedLightWallpaper ?? 0);
            this.dynamicWallpaperStatus.set(
                cached.dynamicWallpaperStatus ?? true
            );
            this.showDesktopWidgetStatus.set(cached.showDesktopWidget ?? true);
        });
    }

    applyCachedTheme() {
        print('Applying cached theme');
        this.changeTheme(this.selectedTheme.get());
    }
}

export const themeManager = new ThemeManager();
export const selectedTheme = themeManager.getSelectedTheme();

const { Service } = ags;
const { USER, exec, execAsync, readFile, writeFile, CACHE_DIR } = ags.Utils;

class ThemeService extends Service {
    static {
        Service.register(this,
            {
                'selected-theme': []
            }
        );
    }

    constructor() {
        super();
        exec('swww init');
        this.setup();
    }

    changeTheme(selectedTheme) {
        Themes.BLACK_HOLE_THEME.css_theme
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

    changeCss(oldTheme, newTheme) {
        const scss = ags.App.configDir + '/scss/main.scss';
        const css = ags.App.configDir + '/style.css';

        execAsync(
            [
                'sed',
                '-i',
                `s/${oldTheme}/${newTheme}/`,
                scss
            ]
            // `sed -i 's/@import \.\/themes\/black-hole\.scss;/@import .\/themes\/deer.scss;/g' ${scss}`
        ).then(() => {
            exec(`sassc ${scss} ${css}`);
            App.resetCss();
            App.applyCss(`${tmp}/style.css`);
        }).catch(print)
    }

    changePlasmaColor(plasmaColor) {
        execAsync([
            PLASMA_COLOR_CHANGER,
            '-c',
            PLASMA_COLORS_PATH,
            plasmaColor
        ]).catch(print);
    }

    changeQtStyle(qtStyle) {
        execAsync([
            'sed',
            '-i',
            `"s/style=.*/style=${qtStyle}/g"`,
            QT_FILE_PATH,
        ]).catch(print);
    }

    changeIcons(icons) {
        execAsync([
            'sed',
            '-i',
            `"s/icon_theme=.*/icon_theme=${icons}/g"`,
            QT_FILE_PATH,
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

class BrightnessService extends Service {
    static {
        // every subclass of GObject.Object has to register itself
        // takes three arguments
        // the class itself
        // an object defining the signals
        // an object defining its properties
        Service.register(
            this,
            {
                // 'name-of-signal': [type as a string from GObject.TYPE_<type>],
                'screen-changed': ['float'],
            },
            {
                // 'kebab-cased-name': [type as a string from GObject.TYPE_<type>, 'r' | 'w' | 'rw']
                // 'r' means readable
                // 'w' means writable
                // guess what 'rw' means
                'screen-value': ['float', 'rw'],
            },
        );
    }

    _screenValue = 0;

    // the getter has to be in snake_case
    get screen_value() { return this._screenValue; }

    // the setter has to be in snake_case too
    set screen_value(percent) {
        if (percent < 0)
            percent = 0;

        if (percent > 1)
            percent = 1;

        Utils.execAsync(`brightnessctl s ${percent * 100}% -q`)
            .then(() => {
                this._screen = percent;

                // signals has to be explicity emitted
                this.emit('changed'); // emits "changed"
                this.notify('screen'); // emits "notify::screen"

                // or use Service.changed(propName: string) which does the above two
                // this.changed('screen');
            })
            .catch(print);
    }

    constructor() {
        super();
        const current = Number(exec('brightnessctl g'));
        const max = Number(exec('brightnessctl m'));
        this._screenValue = current / max;
    }

    // overwriting connectWidget method, let's you
    // change the default event that widgets connect to
    connectWidget(widget, callback, event = 'screen-changed') {
        super.connectWidget(widget, callback, event);
    }
}

// the singleton instance
const service = new BrightnessService();

// make it global for easy use with cli
globalThis.brightness = service;

// export to use in other modules
export default service;
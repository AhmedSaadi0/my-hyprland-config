import themeService from '../services/ThemeService.js';
import settings from '../settings.js';
import strings from '../strings.js';
import ThemesDictionary from '../theme/themes.js';

const { query } = await Service.import('applications');
const WINDOW_NAME = 'applauncher';

/** @param {import('resource:///com/github/Aylur/ags/service/applications.js').Application} app */
const AppItem = (app) =>
    Widget.Button({
        on_clicked: () => {
            App.closeWindow(WINDOW_NAME);
            app.launch();
        },
        attribute: { app },
        child: Widget.Box({
            className: 'app-box',
            spacing: 20,
            children: [
                Widget.Icon({
                    icon: app.icon_name || '',
                    size: 42,
                }),
                Widget.Label({
                    class_name: 'title',
                    label: app.name,
                    xalign: 0,
                    vpack: 'center',
                    truncate: 'end',
                }),
            ],
        }),
    });

const Applauncher = ({ width = 500, height = 500, spacing = 12 }) => {
    // list of application buttons
    let applications = query('').map(AppItem);

    // container holding the buttons
    const list = Widget.Box({
        vertical: true,
        children: applications,
        spacing,
    });

    // repopulate the box, so the most frequent apps are on top of the list
    function repopulate() {
        applications = query('').map(AppItem);
        list.children = applications;
    }

    // search entry
    const entry = Widget.Entry({
        hexpand: true,
        // css: `margin-bottom: 2rem;`,
        className: 'app-search',
        css: `margin: 1.2rem; margin-top: 5rem;`,
        // to launch the first item on Enter
        on_accept: () => {
            // make sure we only consider visible (searched for) applications
            const results = applications.filter((item) => item.visible);
            if (results[0]) {
                App.toggleWindow(WINDOW_NAME);
                results[0].attribute.app.launch();
            }
        },

        // filter out the list
        on_change: ({ text }) =>
            applications.forEach((item) => {
                item.visible = item.attribute.app.match(text ?? '');
            }),
    });

    const applicationMenuHeader = Widget.Box({
        // spacing: 8,
        className: 'app-search-box',
        // css: `min-height:3rem;`,
        vertical: true,
        children: [
            Widget.Label({
                label: `${strings.hello} ${settings.username}`,
                css: 'margin-top:1rem; margin-bottom:2;',
                className: 'applications-header-title',
            }),
            entry,
        ],
    }).hook(themeService, (box) => {
        const selectedTheme = ThemesDictionary[themeService.selectedTheme];

        let wallpaper = selectedTheme.wallpaper;
        if (selectedTheme.dynamic) {
            wallpaper = `${selectedTheme.wallpaper_path}/thumbnail.jpg`;
        }

        box.css = `background-image: url("${wallpaper}");`;
    });

    return Widget.Box({
        vertical: true,
        className: 'applications-box shadow',
        css: `margin: ${spacing * 2}px;`,
        children: [
            applicationMenuHeader,
            // wrap the list in a scrollable
            Widget.Scrollable({
                hscroll: 'never',
                css:
                    `margin:1rem; min-width: ${width}px;` +
                    `min-height: ${height}px;`,
                child: list,
            }),
        ],
        setup: (self) =>
            self.hook(App, (_, windowName, visible) => {
                if (windowName !== WINDOW_NAME) return;

                // when the applauncher shows up
                if (visible) {
                    repopulate();
                    entry.text = '';
                    entry.grab_focus();
                }
            }),
    });
};

// there needs to be only one instance
export const applauncher = Widget.Window({
    name: WINDOW_NAME,
    setup: (self) =>
        self.keybind('Escape', () => {
            App.closeWindow(WINDOW_NAME);
        }),
    visible: false,
    keymode: 'exclusive',
    child: Applauncher({
        width: 500,
        height: 500,
        spacing: 12,
    }),
});

globalThis.showApplauncher = () => {
    if (!applauncher.visible) {
        App.openWindow(WINDOW_NAME);
    }
};

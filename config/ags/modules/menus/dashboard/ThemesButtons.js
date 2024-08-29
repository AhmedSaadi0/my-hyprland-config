import { ThemeButton, TitleText, local } from '../../utils/helpers.js';
import ThemesDictionary, {
    CIRCLES_THEME,
    GOLDEN_THEME,
    HARMONY_THEME,
    NEW_CAT_THEME,
    UNICAT_THEME,
    DARK_THEME,
    GAME_THEME,
    WIN_20,
    BLACK_HOLE_THEME,
    DEER_THEME,
    COLOR_THEME,
    SIBERIAN_THEME,
    MATERIAL_YOU,
    WHITE_FLOWER,
    DYNAMIC_M3_DARK,
    DYNAMIC_M3_LIGHT,
} from '../../theme/themes.js';
import strings from '../../strings.js';
import themeService from '../../services/ThemeService.js';

const blackHoleTheme = ThemeButton({
    label: strings.blackHoleTheme,
    icon: '󰇩',
    theme: BLACK_HOLE_THEME,
});

const deerTheme = ThemeButton({
    label: strings.deerTheme,
    icon: '',
    theme: DEER_THEME,
});

const colorTheme = ThemeButton({
    label: strings.colorTheme,
    icon: '',
    theme: COLOR_THEME,
    // end: '',
});

const siberianTheme = ThemeButton({
    label: strings.siberianTheme,
    icon: '󰚠',
    theme: SIBERIAN_THEME,
});

const materialYouTheme = ThemeButton({
    label: strings.materialYouTheme,
    icon: '󰦆',
    theme: MATERIAL_YOU,
});

const win20Theme = ThemeButton({
    label: strings.win20Theme,
    icon: '󰖳',
    theme: WIN_20,
    end: '',
});

const gameTheme = ThemeButton({
    label: strings.gameTheme,
    icon: '',
    theme: GAME_THEME,
});

const darkTheme = ThemeButton({
    label: strings.darkTheme,
    icon: '󱀝',
    theme: DARK_THEME,
    end: '',
});

const unicatTheme = ThemeButton({
    label: strings.unicatTheme,
    icon: '󰄛',
    theme: UNICAT_THEME,
    end: '',
});

const newCatTheme = ThemeButton({
    label: strings.newCatTheme,
    icon: '',
    theme: NEW_CAT_THEME,
});

const goldenTheme = ThemeButton({
    label: strings.goldenTheme,
    icon: '󰉊',
    theme: GOLDEN_THEME,
    end: '',
});

const harmonyTheme = ThemeButton({
    label: strings.harmonyTheme,
    icon: '󰔉',
    theme: HARMONY_THEME,
    // end: '',
});

const circlesTheme = ThemeButton({
    label: strings.circlesTheme,
    icon: '',
    theme: CIRCLES_THEME,
});

const whiteFlower = ThemeButton({
    label: strings.whiteFlower,
    icon: '',
    theme: WHITE_FLOWER,
});

var dynaicBtn1Css = `
min-height: 2rem;
border-top-right-radius: 1rem;
border-bottom-right-radius: 1rem;
border-top-left-radius: 0rem;
border-bottom-left-radius: 0rem;
`;

var dynaicBtn2Css = `
min-height: 2rem;
border-top-left-radius: 1rem;
border-bottom-left-radius: 1rem;
border-top-right-radius: 0rem;
border-bottom-right-radius: 0rem;
`;

const dynamicTheme = Widget.Box({
    children: [
        ThemeButton({
            label: '',
            icon: '󰖔',
            theme: DYNAMIC_M3_DARK,
            label_css: 'unset',
            icon_css: 'dynamic-theme-btn-icon',
            css: local === 'RTL' ? dynaicBtn1Css : dynaicBtn2Css,
        }),
        ThemeButton({
            label: '',
            icon: '',
            theme: DYNAMIC_M3_LIGHT,
            label_css: 'unset',
            icon_css: 'dynamic-theme-btn-icon',
            css: local !== 'RTL' ? dynaicBtn1Css : dynaicBtn2Css,
            // end: '',
        }),
    ],
});

// --------------------------
// ---------- ROWS ----------
// --------------------------

const visibleThemes1 = Widget.Box({
    children: [colorTheme, harmonyTheme, dynamicTheme],
});

const visibleThemes2 = Widget.Box({
    css: `margin-top: 1rem;`,
    children: [newCatTheme, blackHoleTheme, darkTheme],
});

const row1 = Widget.Box({
    css: `margin-top: 1rem;`,
    children: [siberianTheme, deerTheme, win20Theme],
});

const row2 = Widget.Box({
    css: `margin-top: 1rem;`,
    children: [materialYouTheme, gameTheme, goldenTheme],
});

const row3 = Widget.Box({
    css: `margin-top: 1rem;`,
    children: [circlesTheme, whiteFlower, unicatTheme],
});

const separator = Widget.Separator({
    className: 'themes-settings-separator',
    vertical: false,
});

const showDesktopWidgets = TitleText({
    title: strings.showDesktopWidgets,
    titleClass: 'theme-button-toggle-title',
    titleXalign: 0.1,
    vertical: false,
    spacing: 25,
    textWidget: Widget.Switch({
        active: true,
        onActivate: ({ active }) => {
            const selectedTheme = ThemesDictionary[themeService.selectedTheme];
            if (active) {
                themeService.showWidget(selectedTheme.desktop_widget);
            } else {
                themeService.hideWidget(selectedTheme.desktop_widget);
            }
            themeService.showDesktopWidgetStatus = active;
            themeService.cacheVariables();
        },
    }).hook(themeService, (self) => {
        self.active = themeService.showDesktopWidgetStatus;
    }),
});

const otherThemesRevealer = Widget.Revealer({
    revealChild: false,
    transitionDuration: 500,
    transition: 'slide_down',
    child: Widget.Box({
        vertical: true,
        children: [row1, row2, row3, separator, showDesktopWidgets],
    }),
});

const revealerButton = Widget.Button({
    className: 'view-all-themes-btn',
    label: '',
    onClicked: () => {
        revealAllThemes(!otherThemesRevealer.reveal_child);
        revealMediaControls(false);
        revealPowerButtons(false);
    },
});

globalThis.revealAllThemes = (reveal_child = true) => {
    otherThemesRevealer.reveal_child = reveal_child;
    revealerButton.label = '';

    if (reveal_child) {
        revealerButton.label = '';
    }
};

const themesButtonsRowOne = Widget.Box({
    className: 'themes-box',
    vertical: true,
    children: [
        TitleText({
            title: '',
            titleClass: 'themes-buttons-icon',
            text: strings.themes,
            textClass: 'themes-buttons-title',
            vertical: false,
            titleYalign: 0,
            textYalign: 0,
        }),
        visibleThemes1,
        visibleThemes2,
        otherThemesRevealer,
        revealerButton,
        // Widget.Button({
        //     // css: `margin-top: 1rem;`,
        //     label: '',
        // }),
        // row1,
        // row2,
        // row3,
        // row4,
        // row5,
    ],
});

export default themesButtonsRowOne;

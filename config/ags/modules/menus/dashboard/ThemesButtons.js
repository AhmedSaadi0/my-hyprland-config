import { ThemeButton, local } from '../../utils/helpers.js';
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

const ThemesButtonsRowOne = () => {
    // -----------------------------------
    // ---------- Theme Buttons ----------
    // -----------------------------------
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
        end: '',
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
    });

    const harmonyTheme = ThemeButton({
        label: strings.harmonyTheme,
        icon: '󰔉',
        theme: HARMONY_THEME,
        end: '',
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
                end: '',
            }),
        ],
    });

    // --------------------------
    // ---------- ROWS ----------
    // --------------------------
    const row1 = Widget.Box({
        children: [blackHoleTheme, deerTheme, colorTheme],
    });
    const row2 = Widget.Box({
        css: `
        margin-top: 1rem;
    `,
        children: [siberianTheme, materialYouTheme, win20Theme],
    });
    const row3 = Widget.Box({
        css: `
        margin-top: 1rem;
    `,
        children: [gameTheme, darkTheme, unicatTheme],
    });
    const row4 = Widget.Box({
        css: `
        margin-top: 1rem;
    `,
        children: [newCatTheme, goldenTheme, harmonyTheme],
    });
    const row5 = Widget.Box({
        css: `
        margin-top: 1rem;
    `,
        children: [circlesTheme, whiteFlower, dynamicTheme],
    });

    return Widget.Box({
        className: 'themes-box',
        vertical: true,
        children: [
            Widget.Label({
                className: 'themes-buttons-title',
                label: strings.themes,
                xalign: 0,
            }),
            row1,
            row2,
            row3,
            row4,
            row5,
        ],
    });
};

export default ThemesButtonsRowOne;

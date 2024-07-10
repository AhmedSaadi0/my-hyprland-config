import themeService from '../services/ThemeService.js';
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
} from '../theme/themes.js';
import {
    Label,
    Box,
    Icon,
    Window,
    Button,
    Revealer,
} from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import MusicPLayer from '../widgets/MusicPLayer.js';
import { local } from '../utils/helpers.js';
import settings from '../settings.js';
import { Widget } from '../utils/imports.js';
import strings from '../strings.js';

const Profile = () => {
    const userImage = Icon({
        className: 'profile-icon',
        icon: `${settings.assets.wallpapers}/image.png`,
        size: 80,
    });

    const myName = Label({
        className: 'profile-label',
        label: settings.username,
    });

    return Box({
        className: 'profile-box',
        vertical: true,
        children: [userImage, myName],
    });
};

const Header = () => {
    return Box({
        className: 'left-menu-header',
        vertical: true,
    }).hook(themeService, (box) => {
        const selectedTheme = ThemesDictionary[themeService.selectedTheme];

        let wallpaper = selectedTheme.wallpaper;
        if (selectedTheme.dynamic) {
            wallpaper = `${selectedTheme.wallpaper_path}/thumbnail.jpg`;
        }

        box.css = `background-image: url("${wallpaper}");`;
    });
};

const ThemeButton = ({
    label,
    icon,
    theme,
    label_css = 'theme-btn-label',
    icon_css = 'theme-btn-icon',
    end = local === 'RTL' ? 'margin-left: 1.1rem;' : 'margin-right: 1.1rem;',
    css = `
    min-width: 5rem;
    min-height: 2rem;
    ${end}
    border-radius: 1rem;
`,
}) => {
    const _label = Label({
        className: `unset ${label_css}`,
        label: label,
    });

    const _icon = Label({
        className: `unset ${icon_css}`,
        label: icon,
        xalign: 0.5,
    });

    const box = Box({
        className: 'unset theme-btn-box',
        children: [_label, _icon],
    });

    const button = Button({
        css: css,
        child: box,
        onClicked: () => themeService.changeTheme(theme),
    }).hook(themeService, (btn) => {
        btn.className = 'theme-btn';
        if (themeService.selectedTheme === theme) {
            btn.className = 'selected-theme';
        }
    });

    return button;
};

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
    const row1 = Box({
        children: [blackHoleTheme, deerTheme, colorTheme],
    });
    const row2 = Box({
        css: `
        margin-top: 1rem;
    `,
        children: [siberianTheme, materialYouTheme, win20Theme],
    });
    const row3 = Box({
        css: `
        margin-top: 1rem;
    `,
        children: [gameTheme, darkTheme, unicatTheme],
    });
    const row4 = Box({
        css: `
        margin-top: 1rem;
    `,
        children: [newCatTheme, goldenTheme, harmonyTheme],
    });
    const row5 = Box({
        css: `
        margin-top: 1rem;
    `,
        children: [circlesTheme, whiteFlower, dynamicTheme],
    });

    return Box({
        className: 'themes-box',
        vertical: true,
        children: [row1, row2, row3, row4, row5],
    });
};

const PowerButtonsRow = () => {
    const powerBtnMargin =
        local === 'RTL' ? 'margin-left: 1rem;' : 'margin-right: 1rem;';

    const powerOff = Button({
        className: 'theme-btn',
        css: `
        min-width: 5rem;
        min-height: 2rem;
        border-radius: 1rem;
        ${powerBtnMargin}
    `,
        child: Label({
            label: '',
        }),
        onClicked: () => {
            Utils.execAsync([
                `paplay`,
                settings.assets.audio.desktop_logout,
            ]).catch(print);
            execAsync('systemctl poweroff').catch(print);
        },
    });

    const reboot = Button({
        className: 'theme-btn',
        css: `
        min-width: 5rem;
        min-height: 2rem;
        border-radius: 1rem;
        ${powerBtnMargin}
    `,
        child: Label({
            label: '',
        }),
        onClicked: () => {
            Utils.execAsync([
                `paplay`,
                settings.assets.audio.desktop_logout,
            ]).catch(print);
            execAsync('systemctl reboot').catch(print);
        },
    });

    const logout = Button({
        className: 'theme-btn',
        css: `
        min-width: 5rem;
        min-height: 2rem;
        border-radius: 1rem;
    `,
        child: Label({
            label: '',
        }),
        onClicked: () => {
            Utils.execAsync([
                `paplay`,
                settings.assets.audio.desktop_logout,
            ]).catch(print);
            execAsync('loginctl kill-session self').catch(print);
        },
    });

    const row1 = Box({
        children: [powerOff, reboot, logout],
    });

    return Box({
        className: 'power-box unset',
        css: `
        margin-top:0rem;
    `,
        vertical: true,
        children: [row1],
    });
};

const widgets = Box({
    className: 'left-menu-box unset',
    vertical: true,
    children: [
        Header(),
        Profile(),
        ThemesButtonsRowOne(),
        MusicPLayer('left-menu-music-wd'),
        PowerButtonsRow(),
    ],
});

const menuRevealer = Revealer({
    transition: settings.theme.menuTransitions.leftMenu,
    child: widgets,
    transitionDuration: settings.theme.menuTransitions.leftMenuDuration,
});

export const LeftMenu = ({ monitor } = {}) =>
    Window({
        name: `left_menu_${monitor}`,
        margins: [-2, 0, 0, 0],
        // layer: 'overlay',
        anchor: ['top', local === 'RTL' ? 'left' : 'right'],
        child: Box({
            // className: "left-menu-window",
            css: `
            min-height: 2px;
        `,
            children: [menuRevealer],
        }),
    });

export const MenuButton = () =>
    Button({
        className: 'menu-button unset',
        label: '',
        onClicked: () => {
            menuRevealer.revealChild = !menuRevealer.revealChild;
            changeMenuBtn();
        },
    });

globalThis.showLeftMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild;
    changeMenuBtn();
};

function changeMenuBtn() {
    if (menuRevealer.revealChild) {
        MenuButton.label = '';
    } else {
        MenuButton.label = '';
    }
}

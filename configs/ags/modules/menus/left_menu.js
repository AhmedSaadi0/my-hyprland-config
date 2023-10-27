import themeService from '../services/ThemeService.js';
import ThemesDictionary, { WIN_20 } from "../theme/themes.js";
import { BLACK_HOLE_THEME, DEER_THEME, COLOR_THEME, SIBERIAN_THEME, MATERIAL_YOU } from "../theme/themes.js";
import { Label, Box, Icon, Window, Button, Revealer } from 'resource:///com/github/Aylur/ags/widget.js';
import { USER, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import MusicPLayer from '../widgets/MusicPLayer.js';


const Profile = () => {
    const userImage = Icon({
        className: "profile-icon",
        icon: "/home/ahmed/.config/ags/images/image.png",
        size: 80,
    })

    const myName = Label({
        className: "profile-label",
        label: "احمد الصعدي"
    })

    return Box({
        className: "profile-box",
        vertical: true,
        children: [
            userImage,
            myName,
        ]
    })
}

const Header = () => {
    return Box({
        className: "left-menu-header",
        style: `
            background-image: url("/home/${USER}/.config/ags/images/black-hole.png");
        `,
        vertical: true,
        connections: [
            [themeService, box => {
                let wallpaper = ThemesDictionary[themeService.selectedTheme].wallpaper;
                box.style = `background-image: url("/home/${USER}/${wallpaper}");`;
            }]
        ]
    })
}

const ThemeButton = ({ label, theme, end = "margin-left: 1rem;" }) => Button({
    style: `
            min-width: 5rem;
            min-height: 2rem;
            ${end}
            border-radius: 1rem;
        `,
    child: Label({
        label: label
    }),
    onClicked: () => themeService.changeTheme(theme),
    connections: [
        [themeService, btn => {
            btn.className = "theme-btn";
            if (themeService.selectedTheme === theme) {
                btn.className = "selected-theme";
            }
        }]
    ]
})

const ThemesButtonsRowOne = () => {

    const blackHoleTheme = ThemeButton({
        label: "ثقب    󰇩",
        theme: BLACK_HOLE_THEME
    });

    const deerTheme = ThemeButton({
        label: "غزال  ",
        theme: DEER_THEME
    });

    const colorTheme = ThemeButton({
        label: "جمالي  ",
        theme: COLOR_THEME,
        end: "",
    });

    const SiberianTheme = ThemeButton({
        label: "تدرج  ",
        theme: SIBERIAN_THEME,
    });

    const MaterialYouTheme = ThemeButton({
        label: "مادي ",
        theme: MATERIAL_YOU,
    });

    const Win20Theme = ThemeButton({
        label: "ويندوز ",
        theme: WIN_20,
        end: "",
    });

    const row1 = Box({
        children: [
            blackHoleTheme,
            deerTheme,
            colorTheme
        ]
    })
    const row2 = Box({
        style: `
            margin-top: 1rem;
        `,
        children: [
            SiberianTheme,
            MaterialYouTheme,
            Win20Theme
        ]
    })

    return Box({
        className: "themes-box",
        vertical: true,
        children: [
            row1,
            row2,
        ]
    })
}

const PowerButtonsRow = () => {

    const powerOff = Button({
        className: "theme-btn",
        style: `
                min-width: 5rem;
                min-height: 2rem;
                border-radius: 1rem;
                margin-left: 1rem;
            `,
        child: Label({
            label: ""
        }),
        onClicked: () => execAsync("poweroff").catch(print),
    })

    const reboot = Button({
        className: "theme-btn",
        style: `
                min-width: 5rem;
                min-height: 2rem;
                border-radius: 1rem;
                margin-left: 1rem;
            `,
        child: Label({
            label: ""
        }),
        onClicked: () => execAsync("reboot").catch(print),
    })

    const logout = Button({
        className: "theme-btn",
        style: `
                min-width: 5rem;
                min-height: 2rem;
                border-radius: 1rem;
            `,
        child: Label({
            label: ""
        }),
        onClicked: () => execAsync("loginctl kill-session self").catch(print),
    })


    const row1 = Box({
        children: [
            powerOff,
            reboot,
            logout,
        ]
    })

    return Box({
        className: "themes-box",
        style: `
            margin-top:0rem;
        `,
        vertical: true,
        children: [
            row1,
        ]
    })
}

const menuRevealer = Revealer({
    transition: "slide_down",
    child: Box({
        className: "left-menu-box",
        vertical: true,
        children: [
            Header(),
            Profile(),
            ThemesButtonsRowOne(),
            MusicPLayer("left-menu-music-wd"),
            PowerButtonsRow()
        ]
    }),
})

export const LeftMenu = () => Window({
    name: `left_menu`,
    margin: [0, 0, 0, 0],
    // layer: 'overlay',
    anchor: ['top', "left"],
    child: Box({
        // className: "left-menu-window",
        style: `
            min-height: 0.0001rem;
        `,
        children: [
            menuRevealer,
        ],
    })
})

globalThis.showLeftMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild
    changeMenuBtn();
};

function changeMenuBtn() {
    if (menuRevealer.revealChild) {
        MenuButton.label = "";
    } else {
        MenuButton.label = "";
    }
}

export const MenuButton = Button({
    className: "menu-button",
    label: "",
    onClicked: () => {
        menuRevealer.revealChild = !menuRevealer.revealChild;
        changeMenuBtn();
    }
});

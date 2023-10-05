
import themeService from "../theme/service.js";
import ThemesDictionary from "../theme/themes.js";
import { BLACK_HOLE_THEME, DEER_THEME, COLOR_THEME } from "../theme/themes.js";

const { Label, Box, Icon, Window, Button, Revealer } = ags.Widget;
const { USER } = ags.Utils;


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

const ThemesButtons = () => {

    const blackHoleTheme = Button({
        style: `
            min-width: 5rem;
            min-height: 2rem;
            margin-left: 1rem;
            border-radius: 1rem;
        `,
        child: Label({
            label: "ثقب  󰇩"
        }),
        onClicked: () => themeService.changeTheme(BLACK_HOLE_THEME),
        connections: [
            [themeService, btn => {
                btn.className = "theme-btn";
                if (themeService.selectedTheme === BLACK_HOLE_THEME) {
                    btn.className = "selected-theme";
                }
            }]
        ]
    })

    const deerTheme = Button({
        style: `
            min-width: 5rem;
            min-height: 2rem;
            margin-left: 1rem;
            border-radius: 1rem;
        `,
        child: Label({
            label: "غزال  "
        }),
        onClicked: () => themeService.changeTheme(DEER_THEME),
        connections: [
            [themeService, btn => {
                btn.className = "theme-btn";
                if (themeService.selectedTheme === DEER_THEME) {
                    btn.className = "selected-theme";
                }
            }]
        ]
    })

    const colorTheme = Button({
        style: `
            min-width: 5rem;
            min-height: 2rem;
            border-radius: 1rem;
        `,
        className: "theme-btn",
        child: Label({
            label: "جمالي  "
        }),
        onClicked: () => themeService.changeTheme(COLOR_THEME),
        connections: [
            [themeService, btn => {
                btn.className = "theme-btn";
                if (themeService.selectedTheme === COLOR_THEME) {
                    btn.className = "selected-theme";
                }
            }]
        ],
    })


    return Box({
        className: "themes-box",
        children: [
            blackHoleTheme,
            deerTheme,
            colorTheme,
        ]
    })
}


const Menu = Revealer({
    transition: "slide_down",
    child: Box({
        className: "left-menu-box",
        vertical: true,
        children: [
            Header(),
            Profile(),
            ThemesButtons()
        ]
    })
})


export const LeftMenu = () => Window({
    name: `left_menu`,
    margin: [12, 0, 0, 12],
    // layer: 'overlay',
    anchor: ['top', "left"],
    child: Box({
        style: `
            min-height: 0.0001rem;
        `,
        children: [
            Menu,
        ],
    })
})


export const MenuButton = () => Button({
    className: "menu-button",
    child: Label({ label: "" }),
    onClicked: () => {
        Menu.revealChild = !Menu.revealChild;
    }
});
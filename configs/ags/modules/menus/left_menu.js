
import theme from "../theme/service.js";

const { Label, Box, Icon, Window, Button, Revealer } = ags.Widget;


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
            background-image: url("/home/ahmed/.config/ags/images/black-hole.png");
        `,
        vertical: true,
    })
}

const Themes = () => {

    const blackHoleTheme = Button({
        className: "selected-theme",
        style: `
            min-width: 4.5rem;
            min-height: 2rem;
            margin-left: 1rem;
            border-radius: 1rem;
        `,
        child: Label({
            label: "ثقب  󰇩"
        }),
        onClicked: () => theme.changeTheme(0),
    })

    const deerTheme = Button({
        style: `
            min-width: 4.5rem;
            min-height: 2rem;
            margin-left: 1rem;
            border-radius: 1rem;
        `,
        child: Label({
            label: "غزال  "
        }),
        onClicked: () => theme.changeTheme(1),
        
    })

    const colorTheme = Button({
        style: `
            min-width: 4.5rem;
            min-height: 2rem;
            border-radius: 1rem;
        `,
        child: Label({
            label: "دوائر    "
        }),
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
            Themes()
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
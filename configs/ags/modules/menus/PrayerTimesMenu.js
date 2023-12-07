import { Label, Box, Icon, Window, Button, Revealer } from 'resource:///com/github/Aylur/ags/widget.js';


const menuRevealer = Revealer({
    transition: "slide_down",
    child: Box({
        className: "left-menu-box",
        vertical: true,
        children: []
    }),
})

export const LeftMenu = () => Window({
    name: `prayer_times_menu`,
    margins: [0, 0, 0, 0],
    // layer: 'overlay',
    anchor: ['top', "left"],
    child: Box({
        // className: "left-menu-window",
        css: `
            min-height: 2px;
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

export const MenuButton = Button({
    className: "menu-button",
    label: "",
    onClicked: () => {
        menuRevealer.revealChild = !menuRevealer.revealChild;
        changeMenuBtn();
    }
});

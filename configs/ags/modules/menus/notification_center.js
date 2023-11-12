import { Label, Box, Icon, Window, Button, Revealer } from 'resource:///com/github/Aylur/ags/widget.js';
import { Notifications } from '../utils/imports.js';
import Notification from '../menus/MenuNotification.js';


const MenuBox = () => {

    return Box({
        className: "notification-menu-header",
        vertical: true,
        children: [],
        connections: [[Notifications, self => {

            let notificationList = [];

            const array = Notifications.notifications.reverse();

            for (let index = 0; index < array.length; index++) {
                const element = array[index];
                let line = Box({
                    className: "horizontal-line"
                });
                if (index === array.length - 1) {
                    line = null;
                }

                notificationList.push(
                    Notification(element),
                    line
                );
            }

            if (array.length < 1) {
                notificationList.push(
                    Label({
                        className: "notification-this-is-all",
                        label: "No notification"
                    }),
                )
            }

            self.children = notificationList;

            self.visible = Notifications.notifications.length > 0;
        }]],
    })
}

const menuRevealer = Revealer({
    transition: "slide_down",
    child: Box({
        className: "left-menu-box",
        vertical: true,
        children: [
            MenuBox(),
        ]
    }),
})

export const NotificationCenter = () => Window({
    name: `notification_center`,
    margin: [0, 0, 0, 500],
    // layer: 'overlay',
    anchor: ['top', "left"],
    child: Box({
        style: `
            min-height: 0.0001rem;
        `,
        children: [
            menuRevealer,
        ],
    })
})

globalThis.showNotificationCenter = () => menuRevealer.revealChild = !menuRevealer.revealChild;

// Notification muted  |  | 󰂛 |  
// Notification 󰂜 | 󰂚 |  | 
// Notification Broadcast 󰂞 | 󰂟 | 󰪒 | 
// Notification has data 
export const NotificationCenterButton = () => Button({
    className: "notification-center-button",
    // child: Label({ label: "" }),
    label: "",
    onClicked: () => showNotificationCenter()
});
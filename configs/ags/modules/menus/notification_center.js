import { Label, Box, Window, Button, Revealer } from 'resource:///com/github/Aylur/ags/widget.js';
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

            let noNotifications = Box({
                vertical: true,
                className: "notification-this-is-all",
                children: [
                    Label({
                        className: "no-notification-icon",
                        // label: "󰂛"
                        // label: "",
                        label: "󱇥",
                    }),
                    Label({
                        className: "no-notification-text",
                        label: "لا يوجد اي اشعارات جديدة",
                    }),
                ]
            })

            if (array.length < 1) {
                notificationList.push(noNotifications)
            }

            self.children = [...notificationList];
        }]],
    })
}

const NotificationHeader = () => {

    return Box({
        className: 'notification-header-box',
        // homogeneous: true,
        spacing: 70,
        children: [
            Button({
                className: "unset notification-center-header-clear",
                label: "",
                // label: "",
                // label: "",
                // label: "",
                // label: "",
                // label: "󰅖",
                onClicked: () => Notifications.clear(),
            }),
            Label({
                className: "notification-center-header-text",
                label: "مركز الاشعارات"
            }),
            Button({
                className: "unset notification-center-header-mute",
                label: "󰂚",
                onClicked: () => Notifications.dnd = !Notifications.dnd,
                // label: "",
            })
        ],
        connections: [[Notifications, self => {
            if (Notifications.dnd) {
                self.children[2].label = "󰂛";
            } else {
                self.children[2].label = "󰂚";
            }
        }]]
    })
}

const menuRevealer = Revealer({
    transition: "slide_down",
    child: Box({
        className: "left-menu-box",
        vertical: true,
        children: [
            NotificationHeader(),
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

// Notification muted  |  | 󰂛 |  |  
// Notification 󰂜 | 󰂚 |  | 
// Notification Broadcast 󰂞 | 󰂟 | 󰪒 | 
// Notification has data 
export const NotificationCenterButton = () => Button({
    className: "notification-center-button",
    // child: Label({ label: "" }),
    label: "",
    onClicked: () => showNotificationCenter(),
    connections: [[Notifications, self => {
        if (Notifications.dnd) {
            self.label = "󰂛";
        } else if (Notifications.notifications.length === 0) {
            self.label = "󰂚";
        } else if (Notifications.notifications.length > 0) {
            self.label = "";
        }
    }]]
});
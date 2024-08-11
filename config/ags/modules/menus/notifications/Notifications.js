import Notification from '../../notifications/MenuNotification.js';
import { TitleText, local } from '../../utils/helpers.js';

import settings from '../../settings.js';
import strings from '../../strings.js';
import { Notifications } from '../../utils/imports.js';

const Scrollable = Widget.Scrollable;
const Label = Widget.Label;
const Box = Widget.Box;
const Window = Widget.Window;
const Button = Widget.Button;
const Revealer = Widget.Revealer;

const NotificationsBox = () => {
    return Box({
        className: 'notification-menu-header',
        vertical: true,
        children: [],
    }).hook(Notifications, (self) => {
        let notificationList = [];

        const array = Notifications.notifications.reverse();

        for (let index = 0; index < array.length; index++) {
            const element = array[index];
            let line = Box({
                className: 'horizontal-line',
            });
            if (index === array.length - 1) {
                line = null;
            }

            notificationList.push(Notification(element, true), line);
        }

        let noNotifications = Box({
            vertical: true,
            className: 'notification-this-is-all',
            children: [
                Label({
                    className: 'no-notification-icon',
                    // label: "󰂛"
                    // label: "",
                    label: '󱇥',
                }),
                Label({
                    label: strings.noNotifications,
                }),
            ],
        });

        if (array.length < 1) {
            notificationList.push(noNotifications);
        }

        self.children = [...notificationList];
    });
};

const notificationContainer = Scrollable({
    hscroll: 'never',
    vscroll: 'automatic',
    className: 'notification-center-container',
    child: NotificationsBox(),
});

export default notificationContainer;

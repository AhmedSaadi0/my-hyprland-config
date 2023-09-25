import { ShowWindow } from '../utils.js';
const { Notifications } = ags.Service;
const { Box, Label, Window, Revealer } = ags.Widget;

const NotificationBox = () => Box({
    className: "notification-osd",
    connections: [[Notifications, box => {

        const labelList = [];

        for (let index = 0; index < Notifications.popups.length; index++) {
            const element = Notifications.popups[index];
            labelList.push(
                Label({
                    label: element.summary
                })
            );
        }

        box.children = [
            ...labelList
        ]
    }]]
});

export const NotificationOSD = () => Window({
    name: `notification_osd`,
    focusable: false,
    margin: [0, 0, 50, 50],
    layer: 'overlay',
    popup: true,
    anchor: ['bottom', "left"],
    child: NotificationBox()
})
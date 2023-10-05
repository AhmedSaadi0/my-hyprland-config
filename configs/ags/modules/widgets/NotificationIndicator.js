import HoverRevealer from '../utils/HoverRevealer.js';
const { Label, Icon } = ags.Widget;
const { Notifications } = ags.Service;

export default ({
    direction = 'left',
} = {}) => HoverRevealer({
    className: 'notifications-revealer',

    eventboxConnections: [
        [Notifications, box => {
            box.visible =
                Notifications.notifications.length > 0 || Notifications.dnd;
        }],
        ['button-press-event', () => Notifications.close(Notifications.notifications[0].id)],
    ],
    connections: [[Notifications, revealer => {
        const title = Notifications.notifications[0]?.summary;
        if (revealer._title === title)
            return;

        revealer._title = title;
        revealer.revealChild = true;
        ags.Utils.timeout(3000, () => {
            revealer.revealChild = false;
        });
    }]],
    boxClass: 'notifications-revealer-box',
    direction,
    indicator: Icon({
        connections: [[Notifications, icon => {
            icon.icon = Notifications.dnd
                ? 'notifications-disabled-symbolic'
                : 'preferences-system-notifications-symbolic';
        }]],
    }),
    child: Label({
        style: "margin-left: 0.4rem",
        truncate: 'end',
        maxWidthChars: 40,
        connections: [[Notifications, label => {
            label.label = Notifications.notifications[0]?.summary || '';
        }]],
    }),
});

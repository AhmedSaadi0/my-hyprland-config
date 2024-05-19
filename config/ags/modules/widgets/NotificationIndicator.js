import HoverRevealer from '../utils/HoverRevealer.js';
import { Label, Icon } from 'resource:///com/github/Aylur/ags/widget.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';
import { local } from '../utils/helpers.js';

export default ({ direction = 'left' } = {}) =>
    HoverRevealer({
        className: 'notifications-revealer',
        boxClass: 'notifications-revealer-box',
        direction,
        indicator: Icon().hook(Notifications, (icon) => {
            icon.icon = Notifications.dnd
                ? 'notifications-disabled-symbolic'
                : 'preferences-system-notifications-symbolic';
        }),
        child: Label({
            css:
                local === 'RTL'
                    ? 'margin-left: 0.4rem'
                    : 'margin-right: 0.4rem',
            truncate: 'end',
            maxWidthChars: 40,
        }).hook(Notifications, (label) => {
            label.label = Notifications.notifications[0]?.summary || '';
        }),
    })
        .hook(Notifications, (revealer) => {
            const title = Notifications.notifications[0]?.summary;
            if (revealer._title === title) return;

            revealer._title = title;
            revealer.revealChild = true;
            timeout(3000, () => {
                revealer.revealChild = false;
            });
        })
        .hook(Notifications, (box) => {
            box.visible =
                Notifications.notifications.length > 0 || Notifications.dnd;
        })
        .on('button-press-event', () => {
            Notifications.notifications[0].close();
        });

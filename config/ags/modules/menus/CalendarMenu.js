import { local, TitleText } from '../utils/helpers.js';
import settings from '../settings.js';
const { GLib, Gio } = imports.gi;
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

const createCalendarAndTime = () => {
    const calendar = Widget.Calendar({
        className: 'calendar',
    });

    const timeLabel = Widget.Label({
        className: 'media-menu-header',
    });

    const updateTime = () => {
        execAsync(['date', '+(%I:%M) %A, %d %B'])
            .then((time) => {
                timeLabel.label = time;
            })
            .catch(print);
    };

    // Update the time every minute
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 60, () => {
        updateTime();
        return GLib.SOURCE_CONTINUE;
    });

    updateTime();

    return Widget.Box({
        vertical: true,
        className: 'calendar-menu-box',
        children: [timeLabel, calendar],
    });
};

const CalendarMenuRevealer = () => {
    const calendarAndTimeBox = createCalendarAndTime();

    return Widget.Revealer({
        transition: settings.theme.menuTransitions.calendarMenu,
        transitionDuration: settings.theme.menuTransitions.calendarMenuDuration,
        child: calendarAndTimeBox,
    });
};

const calendarMenuRevealer = CalendarMenuRevealer();

export const CalendarMenu = () =>
    Widget.Window({
        name: `calendar_menu`,
        margins: [2, 800],
        anchor: ['top', local === 'RTL' ? 'left' : 'right'],
        child: Widget.Box({
            css: `
            min-height: 2px;
            min-width: 2px;
        `,
            children: [calendarMenuRevealer],
        }),
    });

globalThis.showCalendarMenu = () => {
    calendarMenuRevealer.revealChild = !calendarMenuRevealer.revealChild;
};

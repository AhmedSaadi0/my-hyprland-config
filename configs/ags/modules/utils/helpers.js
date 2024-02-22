import { Utils, Widget } from './imports.js';

export const TitleText = ({
  title,
  titleClass = '',
  text,
  textClass = '',
  boxClass = '',
  homogeneous = false,
  titleXalign = 0.5,
  textXalign = 0.5,
  vertical = true,
  spacing = 0,
}) => {
  const _title = Widget.Label({
    label: title,
    className: titleClass,
    xalign: titleXalign,
  });

  const _text = Widget.Label({
    label: text,
    className: textClass,
    xalign: textXalign,
  });

  return Widget.Box({
    className: boxClass,
    vertical: vertical,
    homogeneous: homogeneous,
    spacing: spacing,
    children: [_title, _text],
  });
};

export const local = Utils.exec(
  `/home/${Utils.USER}/.config/ags/scripts/lang.sh`
);

export const notify = ({
  tonePath,
  title,
  message,
  icon,
  priority = 'normal',
}) => {
  Utils.execAsync([`paplay`, tonePath]).catch(print);

  Utils.execAsync([`notify-send`, '-u', priority, '-i', icon, title, message]);
};
/**
Widget({
    replacement for properties
    attribute: {
        'custom-prop': 123,
        'another': 'xyz',
    },

    setup: self => self
        .on('some-signal-on-this', self => { }) // replacement for connections
        .hook(gobject, self => { }, 'event') // replacement for connections
        .poll(1000, self => { }) // replacement connections
        .bind('prop', gobject, 'target_prop', v => v) // replacement for binds
    })
 * 
 */


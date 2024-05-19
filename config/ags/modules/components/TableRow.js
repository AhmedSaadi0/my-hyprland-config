import { Widget } from '../utils/imports.js';

let tableRow = ({
    appName = '',
    percentage = '',
    header = false,
    deviceName,
    rightTextMaxWidthChars = 9,
    rightTextXalign = 0,
    leftTextMaxWidthChars = 5,
    leftTextXalign = 1,
}) =>
    Widget.Box({
        className: header
            ? `hardware-${deviceName}-table-row-header`
            : `hardware-${deviceName}-table-row`,
        // spacing: 0,
        children: [
            Widget.Label({
                className: header
                    ? 'table-row-app-name-header'
                    : 'table-row-app-name',
                label: appName,
                justification: 'center',
                truncate: 'end',
                xalign: rightTextXalign,
                maxWidthChars: rightTextMaxWidthChars,
                wrap: true,
                useMarkup: true,
            }),
            Widget.Label({
                className: header
                    ? 'table-row-app-percentage-header'
                    : 'table-row-app-percentage',
                label: percentage,
                justification: 'center',
                truncate: 'end',
                xalign: leftTextXalign,
                maxWidthChars: leftTextMaxWidthChars,
                wrap: true,
                useMarkup: true,
            }),
        ],
    });

export default tableRow;

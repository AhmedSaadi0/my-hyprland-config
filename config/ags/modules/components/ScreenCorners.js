import { Widget } from '../utils/imports.js';
import Gtk from 'gi://Gtk?version=3.0';

const drawingarea = (position) =>
    Widget.DrawingArea({
        // class-name
        className: 'top-corner',
        widthRequest: 30,
        heightRequest: 30,
        drawFn: (self, cr, width, height) => {
            const background = self
                .get_style_context()
                .get_background_color(Gtk.StateFlags.NORMAL);

            const borderRadius = parseFloat(
                self
                    .get_style_context()
                    .get_property('border-radius', Gtk.StateFlags.NORMAL)
            );

            const cornerRadius = borderRadius;
            const shadowWidth = 7;

            // Draw shadow
            cr.setSourceRGBA(0, 0, 0, 0.12);

            if (position === 'top-left') {
                cr.arc(
                    cornerRadius + shadowWidth,
                    cornerRadius + shadowWidth,
                    cornerRadius + shadowWidth,
                    Math.PI,
                    (3 * Math.PI) / 2
                );
                cr.lineTo(0, 0);
            } else if (position === 'top-right') {
                cr.arc(
                    width - cornerRadius - shadowWidth,
                    cornerRadius + shadowWidth,
                    cornerRadius + shadowWidth,
                    (3 * Math.PI) / 2,
                    2 * Math.PI
                );
                cr.lineTo(width, 0);
            }

            cr.fill();

            // Draw main shape
            if (position === 'top-left') {
                cr.arc(
                    cornerRadius,
                    cornerRadius,
                    cornerRadius,
                    Math.PI,
                    (3 * Math.PI) / 2
                );
                cr.lineTo(0, 0);
            } else if (position === 'top-right') {
                cr.arc(
                    width - cornerRadius,
                    cornerRadius,
                    cornerRadius,
                    (3 * Math.PI) / 2,
                    2 * Math.PI
                );
                cr.lineTo(width, 0);
            }

            cr.closePath();
            cr.setSourceRGBA(
                background.red,
                background.green,
                background.blue,
                background.alpha
            );
            cr.fill();
        },
    });

export const TopLeftCorner = ({ monitor } = {}) =>
    Widget.Window({
        name: `top_left_corner_m_${monitor}`,
        layer: 'top',
        margins: [-7, 0],
        anchor: ['top', 'left'],
        exclusivity: 'normal',
        visible: true,
        monitor: monitor,
        child: drawingarea('top-left'),
        click_through: true,
    });

export const TopRightCorner = ({ monitor } = {}) =>
    Widget.Window({
        name: `top_right_corner_m_${monitor}`,
        layer: 'top',
        margins: [-7, 0],
        anchor: ['top', 'right'],
        exclusivity: 'normal',
        visible: true,
        monitor: monitor,
        child: drawingarea('top-right'),
        click_through: true,
    });

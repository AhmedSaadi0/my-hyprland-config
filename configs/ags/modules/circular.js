const Cairo = imports.cairo;
const GObject = imports.gi.GObject;
const { Gtk, Clutter } = imports.gi;

export class CircularProgressBarBin2 extends Gtk.Bin {
    static {
        GObject.registerClass(
            {
                GTypeName: 'CircularProgressBarBin2',
            },
            this
        );
    }

    constructor(args = {}) {
        super();

        this.angle = 0;
        this.progress = 0;

        if (args.className) {
            this.className = args.className;
        }
        if (args.childWidget) {
            this.childWidget = args.childWidget;
            this.add(args.childWidget);
        }

        this.connect('draw', this.onDraw.bind(this));
    }

    updateProgress(newProgress) {
        this.progress = newProgress;
        if (this.progress > 100) {
            this.progress = 0;
        }
        this.angle = this.progress * 3.6; // Each percent corresponds to 3.6 degrees
        this.queue_draw();
        return true;
    }

    vfunc_get_preferred_height() {
        let minHeight = this.get_style_context().get_property('min-height', Gtk.StateFlags.NORMAL);
        if (minHeight <= 0) {
            minHeight = 40;
        }
        return [minHeight, minHeight];
    }

    vfunc_get_preferred_width() {
        let minWidth = this.get_style_context().get_property('min-width', Gtk.StateFlags.NORMAL);
        if (minWidth <= 0) {
            minWidth = 40;
        }
        return [minWidth, minWidth];
    }

    onDraw(_widget, cr) {
        const allocation = this.get_allocation();
        const width = allocation.width;
        const height = allocation.height;
        const radius = Math.min(width, height) / 2.5;
        const centerX = width / 2;
        const centerY = height / 2;
        let startAngle = -Math.PI / 90;

        const styles = this.get_style_context();

        for (let index = 0; index < this.className.length; index++) {
            const element = this.className[index];
            styles.add_class(element);
        }

        const progressColor = styles.get_color(Gtk.StateFlags.NORMAL);
        const progressBackgroundColor = styles.get_background_color(Gtk.StateFlags.NORMAL);
        const margin = styles.get_margin(Gtk.StateFlags.NORMAL);

        let fontSize = styles.get_property('font-size', Gtk.StateFlags.NORMAL);

        if (fontSize === 14.666666666666666) {
            fontSize = 2;
        }

        // Draw background circle outline
        cr.setSourceRGBA(
            progressBackgroundColor.red,
            progressBackgroundColor.green,
            progressBackgroundColor.blue,
            progressBackgroundColor.alpha
        );
        cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
        cr.setLineWidth(fontSize);
        cr.stroke();

        // Draw progress arc outline
        cr.setSourceRGBA(
            progressColor.red,
            progressColor.green,
            progressColor.blue,
            progressColor.alpha
        );
        cr.arc(
            centerX,
            centerY,
            radius,
            startAngle,
            startAngle + (Math.PI / 180) * this.angle
        );
        cr.setLineWidth(fontSize);
        cr.stroke();

        if (this.childWidget) {
            const label_width = this.childWidget.get_allocation().width;
            const label_height = this.childWidget.get_allocation().height;
            const label_x = centerX - (label_width / 2);
            const label_y = centerY - (label_height / 2);

            Clutter.Actor.set_position(this.childWidget, label_x, label_y);
        }
    }
}

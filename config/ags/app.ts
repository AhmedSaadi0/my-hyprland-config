import { App, exec } from 'astal';
import Bar from './modules/bars/Top';

const scss = '/home/ahmed/.config/ags_v2/scss/main.scss';
const style = '/home/ahmed/.cache/ags_v2_style.css';

exec(`sassc ${scss} ${style}`);

App.start({
    css: style,
    main() {
        Bar(0);
    },
});

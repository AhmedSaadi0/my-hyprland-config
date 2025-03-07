import { App } from 'astal/gtk3';
// import style from './style.scss';
import Bar from './src/topbar/Topbar';
import { exec } from 'astal';
import { MainMenu } from './src/menus/LeftMenu';

const scss = '/home/ahmed/.config/ags_v2/scss/main.scss';
const style = '/home/ahmed/.cache/ahmed_config_style.css';

exec(`sassc ${scss} ${style}`);

App.start({
    css: style,
    main() {
        App.get_monitors().map(Bar);
        App.get_monitors().map(MainMenu);
    },
});

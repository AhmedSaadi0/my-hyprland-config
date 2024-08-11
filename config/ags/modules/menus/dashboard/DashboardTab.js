import MediaControl from './MediaControl.js';
import PowerButtonsRow from './PowerButtons.js';
import ThemesButtonsRowOne from './ThemesButtons.js';

const dashboardTab = Widget.Box({
    vertical: true,
    children: [ThemesButtonsRowOne(), MediaControl(), PowerButtonsRow()],
});

export default dashboardTab;

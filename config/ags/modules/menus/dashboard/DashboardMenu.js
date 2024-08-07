import MediaControl from './MediaControl.js';
import PowerButtonsRow from './PowerButtonsRow.js';
import ThemesButtonsRowOne from './ThemesButtonsRowOne.js';

const dashboardTab = Widget.Box({
    vertical: true,
    children: [ThemesButtonsRowOne(), MediaControl(), PowerButtonsRow()],
});

export default dashboardTab;

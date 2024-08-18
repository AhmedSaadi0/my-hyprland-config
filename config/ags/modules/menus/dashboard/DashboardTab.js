import mediaControl from './MediaControl.js';
import powerButtonsRow from './PowerButtons.js';
import powerProfileButtons from './PowerProfileButtons.js';
import themesButtonsRowOne from './ThemesButtons.js';

const dashboardTab = Widget.Box({
    vertical: true,
    children: [
        themesButtonsRowOne,
        powerProfileButtons,
        mediaControl,
        powerButtonsRow,
    ],
});

export default dashboardTab;

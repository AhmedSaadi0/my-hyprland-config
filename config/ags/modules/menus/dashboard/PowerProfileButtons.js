import strings from '../../strings.js';
import { TitleText } from '../../utils/helpers.js';
const powerProfiles = await Service.import('powerprofiles');

const highPerformance = Widget.Button({
    className: 'theme-btn',
    css: `min-height: 2rem;border-radius: 1rem;`,
    label: strings.highPerformance,
    on_clicked: () => (powerProfiles.active_profile = 'performance'),
});

const normalPerformance = Widget.Button({
    className: 'theme-btn',
    css: `min-height: 2rem;border-radius: 1rem;`,
    label: strings.balanced,
    on_clicked: () => (powerProfiles.active_profile = 'balanced'),
});

const lowPerformance = Widget.Button({
    className: 'theme-btn',
    css: `min-height: 2rem; border-radius: 1rem;`,
    label: strings.powerSaver,
    on_clicked: () => (powerProfiles.active_profile = 'power-saver'),
});

const title = TitleText({
    title: '󰎓',
    titleClass: 'themes-buttons-icon',
    text: strings.powerProfile,
    textClass: 'themes-buttons-title',
    vertical: false,
    titleYalign: 0,
    textYalign: 0,
});

const buttonsRow = Widget.Box({
    homogeneous: true,
    spacing: 15,
    children: [highPerformance, normalPerformance, lowPerformance],
}).hook(powerProfiles, (self) => {
    self.children[0].className = 'theme-btn';
    self.children[1].className = 'theme-btn';
    self.children[2].className = 'theme-btn';

    if (powerProfiles.active_profile == 'performance') {
        self.children[0].className =
            'power-profiles-box-btn power-profiles-box-btn-active';
    } else if (powerProfiles.active_profile == 'balanced') {
        self.children[1].className =
            'power-profiles-box-btn power-profiles-box-btn-active';
    } else if (powerProfiles.active_profile == 'power-saver') {
        self.children[2].className =
            'power-profiles-box-btn power-profiles-box-btn-active';
    }
});

export default Widget.Box({
    css: 'margin-bottom: 1rem;',
    className: 'left-menu-insider-box',
    vertical: true,
    children: [title, buttonsRow],
});

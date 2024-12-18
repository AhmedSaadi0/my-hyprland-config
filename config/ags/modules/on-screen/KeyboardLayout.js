import ShowWindow from '../utils/ShowWindow.js';
import { TitleText } from '../utils/helpers.js';

const languageLayoutLabelArgs = {
    className: 'language-layout-label',
};

const layout = TitleText({
    title: '󰌌',
    text: 'EN',
    titleClass: 'language-layout-icon',
    textClass: 'language-layout-label',
    boxClass: 'language-layout-box',
    vertical: false,
});

export const languageLayoutOSD = Widget.Window({
    name: `language_layout_ods`,
    focusable: false,
    margins: [200],
    layer: 'overlay',
    visible: false,
    // popup: true,
    anchor: ['bottom'],
    child: layout,
});

globalThis.showKeyboardLayout = () => {
    ShowWindow('language_layout_ods', 2000);

    const availableLanguages = Utils.exec('hyprctl devices -j');
    const languages = JSON.parse(availableLanguages);
    const active_keymap = languages.keyboards[2].active_keymap;

    layout.children[1].label = active_keymap;
};

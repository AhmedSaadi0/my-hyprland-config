import { bind, timeout } from 'astal';
import { selectedTheme, themeManager } from '../utils/theme-manager';
import { TitleText } from './TitleText';
import { hideMainMenu } from '../menus/LeftMenu';

interface ThemeButtonProps {
    title: string;
    icon: string;
    theme: number;
    titleClass?: string;
    iconClass?: string;
    end?: string;
    css?: string;
}

export const ThemeButton = ({
    title,
    icon,
    theme,
    titleClass = 'theme-btn-label',
    iconClass = 'theme-btn-icon',
    end = 'RTL' === 'RTL' ? 'margin-left: 1.1rem;' : 'margin-right: 1.1rem;',
    css = `
        ${end}
        border-radius: 1rem;
    `,
}: ThemeButtonProps) => {
    return (
        <TitleText
            title={title}
            titleClass={titleClass}
            text={icon}
            textClass={iconClass}
            boxClass="unset theme-btn-box"
            onClicked={() => {
                themeManager.changeTheme(theme);
                timeout(200, () => hideMainMenu());
            }}
            eventBoxCss={css}
            eventBoxClass={bind(selectedTheme).as((value) =>
                value === theme ? 'unset selected-theme' : 'unset theme-btn'
            )}
        />
    );
};

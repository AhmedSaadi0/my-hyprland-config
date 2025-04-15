import strings, { local } from '../../utils/strings';
import {
    CIRCLES_THEME,
    COLOR_THEME,
    DARK_THEME,
    DEER_THEME,
    DYNAMIC_M3_DARK,
    DYNAMIC_M3_LIGHT,
    GOLDEN_THEME,
    HARMONY_THEME,
    MATERIAL_YOU,
    WIN_20,
} from '../../utils/themes';
import { ThemeButton } from '../../widgets/ThemeButton';

export const colorsTheme = (
    <ThemeButton title={strings.colorTheme} icon="" theme={COLOR_THEME} />
);

export const harmonyTheme = (
    <ThemeButton title={strings.harmonyTheme} icon="󰔉" theme={HARMONY_THEME} />
);

export const deerTheme = (
    <ThemeButton title={strings.deerTheme} icon="" theme={DEER_THEME} />
);

export const materialYouTheme = (
    <ThemeButton
        title={strings.materialYouTheme}
        icon="󰦆"
        theme={MATERIAL_YOU}
    />
);

export const win30Theme = (
    <ThemeButton title={strings.win20Theme} icon="󰖳" theme={WIN_20} />
);

export const darkTheme = (
    <ThemeButton title={strings.darkTheme} icon="󱀝" theme={DARK_THEME} />
);

export const goldenTheme = (
    <ThemeButton title={strings.goldenTheme} icon="󰉊" theme={GOLDEN_THEME} />
);

export const circlesTheme = (
    <ThemeButton title={strings.circlesTheme} icon="" theme={CIRCLES_THEME} />
);

var dynamicBtn1Css = `
    min-height: 2rem;
    border-top-right-radius: 1rem;
    border-bottom-right-radius: 1rem;
    border-top-left-radius: 0rem;
    border-bottom-left-radius: 0rem;
`;

var dynamicBtn2Css = `
    min-height: 2rem;
    border-top-left-radius: 1rem;
    border-bottom-left-radius: 1rem;
    border-top-right-radius: 0rem;
    border-bottom-right-radius: 0rem;
`;

const dynamicTheme = (
    <box>
        <ThemeButton
            title=""
            icon="󰖔"
            theme={DYNAMIC_M3_DARK}
            titleClass="unset"
            iconClass="dynamic-theme-btn-icon"
            css={local === 'RTL' ? dynamicBtn1Css : dynamicBtn2Css}
        />
        <ThemeButton
            title=""
            icon=""
            theme={DYNAMIC_M3_LIGHT}
            titleClass="unset"
            iconClass="dynamic-theme-btn-icon"
            css={local === 'RTL' ? dynamicBtn2Css : dynamicBtn1Css}
        />
    </box>
);

const visibleThemesRow1 = (
    <box css="margin-bottom: 1rem;">
        {colorsTheme}
        {harmonyTheme}
        {dynamicTheme}
    </box>
);

const visibleThemesRow2 = (
    <box css="margin-bottom: 1rem;">
        {darkTheme}
        {circlesTheme}
        {materialYouTheme}
    </box>
);

const unvisibleThemesRow3 = (
    <box css="margin-bottom: 1rem;">
        {win30Theme}
        {deerTheme}
        {goldenTheme}
    </box>
);

export const themesBox = (
    <box className="themes-box" vertical={true}>
        {visibleThemesRow1}
        {visibleThemesRow2}
        {unvisibleThemesRow3}
    </box>
);

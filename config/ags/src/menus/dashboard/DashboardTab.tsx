import settings from '../../utils/settings';
import PowerButtons from './PowerButtons';
import PowerProfileButtons from './PowerProfileButtons';
import ThemesButtons from './ThemesButtons';

export default (
    <box name={settings.menuTabs.dashboard} vertical={true}>
        {ThemesButtons}
        {PowerProfileButtons}
        {PowerButtons}
    </box>
);

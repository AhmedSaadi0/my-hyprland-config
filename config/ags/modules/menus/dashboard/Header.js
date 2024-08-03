import themeService from '../../services/ThemeService.js';
import settings from '../../settings.js';
import ThemesDictionary from '../../theme/themes.js';

const Header = () => {
    return Widget.Box({
        className: 'left-menu-header',
        vertical: true,
    }).hook(themeService, (box) => {
        const selectedTheme = ThemesDictionary[themeService.selectedTheme];

        let wallpaper = selectedTheme.wallpaper;
        if (selectedTheme.dynamic) {
            wallpaper = `${selectedTheme.wallpaper_path}/thumbnail.jpg`;
        }

        box.css = `background-image: url("${wallpaper}");`;
    });
};

export default Header;

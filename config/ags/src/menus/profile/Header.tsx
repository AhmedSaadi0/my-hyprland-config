import { Box } from 'astal/gtk3/widget';

const Header = (): any => {
    return new Box({
        className: 'main-menu-header-background',
        vertical: true,
        css: `background-image: url("/home/ahmed/.config/ags_v2/assets/wallpapers/win.jpg");`,
    });

    // .hook(themeService, (box: any) => {
    //     const selectedTheme = ThemesDictionary[themeService.selectedTheme];
    //     let wallpaper = selectedTheme.wallpaper;
    //     if (selectedTheme.dynamic) {
    //         wallpaper = `${selectedTheme.wallpaper_path}/thumbnail.jpg`;
    //     }
    //     box.css = `background-image: url("${wallpaper}");`;
    // });
};

export default Header;

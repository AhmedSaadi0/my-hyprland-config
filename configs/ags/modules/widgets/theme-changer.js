const { Service } = ags;
const { USER, exec, execAsync, readFile, writeFile, CACHE_DIR } = ags.Utils;



function setupWallpaper() {
    execAsync([
        'swww', 'img',
        '--transition-type', 'grow',
        '--transition-pos', exec('hyprctl cursorpos').replace(' ', ''),
        this.getSetting('wallpaper'),
    ]).catch(print);
}
import Gdk from 'gi://Gdk';
import { Mpris, Utils, Widget } from '../utils/imports.js';
import { local } from '../utils/helpers.js';
import strings from '../strings.js';
import settings from '../settings.js';

export var selectedMusicPlayer = null;
const PLAYER_MENU_ARROW = '🞃';

class PlayersMenu {
    constructor() {
        this.menu = Widget.Menu({
            children: [],
        });
    }

    popup(event) {
        this.menu.popup_at_widget(
            event,
            Gdk.Gravity.SOUTH,
            Gdk.Gravity.NORTH,
            null
        );
    }

    setChildren(children) {
        this.menu.children = children;
    }
}

const length = () =>
    Widget.Label({
        css: `
      min-width: 4rem;
    `,
        label: '',
        className: 'music-wd-length',
        vexpand: false,
        maxWidthChars: 4,
    });

const RowOne = () => {
    let playerName = Widget.Label({
        css: `
      min-width: 6rem;
    `,
        label: '',
        justification: 'right',
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 10,
        wrap: true,
        useMarkup: true,
    });

    const playersMenu = new PlayersMenu();

    const selectPlayerBtn = Widget.Button({
        className: 'music-wd-player',
        child: playerName,
        onClicked: (event) => {
            playersMenu.popup(event);
        },
    });

    return Widget.Box({
        className: 'music-wd-row-one',
        // homogeneous: true,
        spacing: 100,
        children: [length(), selectPlayerBtn],
    }).hook(Mpris, (self) => {
        let playersList = [];
        for (const player in Mpris.players) {
            if (Object.hasOwnProperty.call(Mpris.players, player)) {
                const element = Mpris.players[player];
                playersList.push(
                    Widget.MenuItem({
                        child: Widget.Label({
                            label: element.name,
                            xalign: 0.5,
                        }),
                        onActivate: () => {
                            playerName.label = `${PLAYER_MENU_ARROW} ${element.name}`;
                            selectedMusicPlayer = element.name;
                            Mpris.emit('changed');

                            Utils.execAsync([
                                'sed',
                                '-i',
                                `24s|.*|playerctl -p ${selectedMusicPlayer} "$command"|`,
                                settings.scripts.playerctl,
                            ]);
                        },
                    })
                );
            }
        }
        playersMenu.setChildren(playersList);

        if (playersList.length > 0 && selectedMusicPlayer === null) {
            playerName.label = `${PLAYER_MENU_ARROW} ${playersList[0].child.label}`;
            selectedMusicPlayer = playersList[0].child.label;
        }

        let player = Mpris.getPlayer(selectedMusicPlayer);

        const songLengthInSeconds = player?.length;
        const minutes = Math.floor(songLengthInSeconds / 60);
        const seconds = Math.round(songLengthInSeconds % 60);

        if (minutes && seconds) {
            self.children[0].label = `${minutes}:${seconds}   `;
        }
    });
};

const RowTwo = () => {
    let title = Widget.Label({
        className: 'music-wd-title',
        justification: 'left',
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
        wrap: true,
        useMarkup: true,
    });
    let artist = Widget.Label({
        className: 'music-wd-file-name',
        justification: 'left',
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 1,
        vexpand: false,
    });
    return Widget.Box({
        vertical: true,
        className: 'music-wd-row-two',
        children: [title, artist],
    }).hook(Mpris, (self) => {
        let player = Mpris.getPlayer(selectedMusicPlayer);

        if (player !== null) {
            title.label = player?.trackTitle;
            artist.label = player?.trackArtists[0];
        } else {
            title.label = strings.musicPlayerNoTitle;
            artist.label = strings.musicPlayerNoArtist;
        }
    });
};

const ButtonsRow = () => {
    let backBtn = Widget.Button({
        className: 'unset music-wd-button',
        label: local === 'RTL' ? '' : '',
        onClicked: () => {
            Mpris.getPlayer(selectedMusicPlayer)?.previous();
        },
    });
    let playBtn = Widget.Button({
        className: 'unset music-wd-button-play',
        label: '',
        onClicked: () => {
            Mpris.getPlayer(selectedMusicPlayer)?.playPause();
        },
    });
    let nextBtn = Widget.Button({
        className: 'unset music-wd-button',
        label: local === 'RTL' ? '' : '',
        onClicked: () => {
            Mpris.getPlayer(selectedMusicPlayer)?.next();
        },
    });
    let skipForwardBtn = Widget.Button({
        className: 'unset music-wd-button',
        // label: "",
        label: local === 'RTL' ? '' : '',
        css: `
            ${local === 'RTL' ? 'padding-right: 2px;' : 'padding-left: 2px;'}
        `,
        // onClicked: () => Audio.speaker.volume = Audio.speaker.volume + 0.1
        onClicked: () => {
            const decimalNumber =
                Mpris.getPlayer(selectedMusicPlayer)?.position;

            Utils.execAsync([
                'playerctl',
                '-p',
                selectedMusicPlayer,
                'position',
                `${decimalNumber + 10}`,
            ]).catch(print);
        },
    });
    let skipBackwardBtn = Widget.Button({
        css: `
            padding-left: 2px;
        `,
        className: 'unset music-wd-button',
        // label: "",
        label: local === 'RTL' ? '' : '',
        onClicked: () => {
            const decimalNumber =
                Mpris.getPlayer(selectedMusicPlayer)?.position;

            Utils.execAsync([
                'playerctl',
                '-p',
                selectedMusicPlayer,
                'position',
                `${decimalNumber - 10}`,
            ]).catch(print);
        },
    });

    return Widget.Box({
        className: 'music-wd-row-three',
        spacing: 11,
        // homogeneous: true,
        children: [backBtn, playBtn, nextBtn, skipBackwardBtn, skipForwardBtn],
    }).hook(Mpris, (self) => {
        let player = Mpris.getPlayer(selectedMusicPlayer);
        nextBtn.set_sensitive(player?.canGoNext);
        backBtn.set_sensitive(player?.canGoPrev);
        playBtn.set_sensitive(player?.canPlay);

        if (player?.playBackStatus === 'Playing') {
            playBtn.label = '';
            playBtn.className = 'unset music-wd-button-play';
        } else if (player?.playBackStatus === 'Paused') {
            // playBtn.label = "⏯";
            playBtn.label = '';
            playBtn.className = 'unset music-wd-button-stop';
        } else if (player?.playBackStatus === 'Stopped') {
            playBtn.label = '';
            playBtn.className = 'unset music-wd-button-stop';
        }
    });
};

export default (className) =>
    Widget.Box({
        className: className || 'music-wd-box',
        vertical: true,
        children: [RowOne(), RowTwo(), ButtonsRow()],
    });

globalThis.mp = () => {
    Mpris.players;
};

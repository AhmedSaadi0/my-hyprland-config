import { Box, Slider, Label, Button, MenuItem, Menu } from 'resource:///com/github/Aylur/ags/widget.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Gdk from 'gi://Gdk';
import { Utils } from '../utils/imports.js';

var selectedMusicPlayer = null;
const PLAYER_MENU_ARROW = "🞃"

class PlayersMenu {
    constructor() {
        this.menu = Menu({
            children: [],
        });
    }

    popup(event) {
        this.menu.popup_at_widget(event, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null);
    }

    setChildren(children) {
        this.menu.children = children;
    }
}

let length = Label({
    style: `
        min-width: 2rem;
    `,
    label: "",
    className: "music-wd-length",
    vexpand: false,
    maxWidthChars: 4,

});

const RowOne = () => {

    let playerName = Label({
        style: `
            min-width: 6.5rem;
        `,
        label: "",
        xalign: 1,
        maxWidthChars: 12,
        vexpand: false,
    });

    const playersMenu = new PlayersMenu();

    const selectPlayerBtn = Button({
        className: "music-wd-player",
        child: playerName,
        onClicked: (event) => {
            playersMenu.popup(event);
        },
    });

    return Box({
        className: "music-wd-row-one",
        // homogeneous: true,
        spacing: 130,
        children: [
            length,
            selectPlayerBtn,
        ],
        connections: [[Mpris, self => {
            let playersList = []
            for (const player in Mpris.players) {
                if (Object.hasOwnProperty.call(Mpris.players, player)) {
                    const element = Mpris.players[player];
                    playersList.push(
                        MenuItem({
                            child: Label({
                                label: element.name,
                                xalign: 0.5,
                            }),
                            onActivate: () => {
                                playerName.label = `${PLAYER_MENU_ARROW} ${element.name}`;
                                selectedMusicPlayer = element.name;
                                Mpris.emit("changed");
                            }
                        }),
                    )
                }
            }
            playersMenu.setChildren(playersList);
            if (selectedMusicPlayer == null) {
                playerName.label = `${PLAYER_MENU_ARROW} ${playersList[0].child.label}`;
                selectedMusicPlayer = playersList[0].child.label;
            }
        }]],
    })
}

const RowTwo = () => {
    let title = Label({
        className: "music-wd-title",
        justification: 'left',
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 1,
        vexpand: false,
    });
    let artist = Label({
        className: "music-wd-file-name",
        justification: 'left',
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 1,
        vexpand: false,
    });
    return Box({
        vertical: true,
        className: "music-wd-row-two",
        children: [
            title,
            artist
        ],
        connections: [[Mpris, self => {
            let player = Mpris.getPlayer(selectedMusicPlayer);

            if (player !== null) {
                title.label = player?.trackTitle;
                artist.label = player?.trackArtists[0];
            }

            const songLengthInSeconds = player?.length;
            const minutes = Math.floor(songLengthInSeconds / 60);
            const seconds = songLengthInSeconds % 60;

            length.label = `${minutes}:${seconds} `;
        }]]
    })
}

const ButtonsRow = () => {

    let backBtn = Button({
        className: "unset music-wd-button",
        label: "",
        onClicked: () => { Mpris.getPlayer(selectedMusicPlayer)?.previous() },
    })
    let playBtn = Button({
        className: "unset music-wd-button-play",
        label: "",
        onClicked: () => { Mpris.getPlayer(selectedMusicPlayer)?.playPause() },
    })
    let nextBtn = Button({
        className: "unset music-wd-button",
        label: "",
        onClicked: () => { Mpris.getPlayer(selectedMusicPlayer)?.next() },
    })
    let skipForwardBtn = Button({
        className: "unset music-wd-button",
        // label: "",
        label: "",
        style: `
            padding-right: 2px;
        `,
        // onClicked: () => Audio.speaker.volume = Audio.speaker.volume + 0.1
        onClicked: () => {
            const decimalNumber = Mpris.getPlayer(selectedMusicPlayer)?.position;

            Utils.execAsync([
                'playerctl',
                '-p',
                selectedMusicPlayer,
                'position',
                `${decimalNumber + 10}`,
            ]).catch(print)
        }
    })
    let skipBackwardBtn = Button({
        style: `
            padding-left: 2px;
        `,
        className: "unset music-wd-button",
        label: "",
        onClicked: () => {
            const decimalNumber = Mpris.getPlayer(selectedMusicPlayer)?.position;

            Utils.execAsync([
                'playerctl',
                '-p',
                selectedMusicPlayer,
                'position',
                `${decimalNumber - 10}`,
            ]).catch(print)
        }
    })

    return Box({
        className: "music-wd-row-three",
        spacing: 10,
        // homogeneous: true,
        children: [
            backBtn,
            playBtn,
            nextBtn,
            skipBackwardBtn,
            skipForwardBtn,
        ],
        connections: [[Mpris, self => {
            let player = Mpris.getPlayer(selectedMusicPlayer);
            nextBtn.set_sensitive(player?.canGoNext);
            backBtn.set_sensitive(player?.canGoPrev);
            playBtn.set_sensitive(player?.canPlay);

            if (player?.playBackStatus === "Playing") {
                playBtn.label = "⏸";
                playBtn.className = "unset music-wd-button-play";
            } else if (player?.playBackStatus === "Paused") {
                // playBtn.label = "⏯";
                playBtn.label = "";
                playBtn.className = "unset music-wd-button-stop";
            } else if (player?.playBackStatus === "Stopped") {
                playBtn.label = "";
                playBtn.className = "unset music-wd-button-stop";
            }

        }]]
    })
}

// export default widget => Box({
//     className: "music-wd-box",
//     vertical: true,
//     children: [
//         RowOne(),
//         RowTwo(),
//         // Prog(),
//         ButtonsRow(),
//     ]
// })

export default className => Box({
    className: className || "music-wd-box",
    vertical: true,
    children: [
        RowOne(),
        RowTwo(),
        ButtonsRow(),
    ]
});

import { TitleText, TitleTextRevealer2 } from '../../utils/helpers.js';

const network = await Service.import('network');

const connectedWifi = TitleText({
    titleClass: 'themes-buttons-icon',
    textClass: 'themes-buttons-icon',
    title: '',
    text: '',
    vertical: false,
    spacing: 20,
}).hook(network, (self) => {
    self.children[1].label = network.wifi.ssid;
    self.children[0].label = setConnectedWifiIcon(network);
});

function setConnectedWifiIcon(network) {
    if (network.wifi?.internet === 'disconnected') {
        return '󰤮';
    }
    if (network.connectivity === 'limited') {
        return '󰤩';
    }

    return setWifiIcon(network.wifi?.strength);
}

function setWifiIcon(strength) {
    if (strength > 85) {
        return '󰤨';
    }
    if (strength > 70) {
        return '󰤥';
    }
    if (strength > 50) {
        return '󰤢';
    }
    if (strength > 20) {
        return '󰤟';
    }
    return '󰤯';
}

const WifiItem = ({
    strength,
    ssid,
    titleClass = 'themes-buttons-icon',
    textClass = 'themes-buttons-icon',
}) => {
    return TitleTextRevealer2({
        titleWidget: TitleText({
            titleClass: titleClass,
            textClass: textClass,
            title: setWifiIcon(strength),
            text: ssid,
            vertical: false,
            spacing: 20,
        }),
        textWidget: Widget.Entry({
            placeholder_text: 'Password',
            visibility: false, // set to false for passwords
            onAccept: ({ text }) => print(text),
        }),
        buttonClass: 'unset un-hover',
        revealerClass: 'unset',
        onHover: null,
        onHoverLost: null,
        onClicked: (btn) => {
            btn.get_parent().children[1].reveal_child =
                !btn.get_parent().children[1].reveal_child;
        },
    });
};

const connectedWifiDetailsBox = Widget.Box({
    className: 'themes-box',
    vertical: true,
    children: [connectedWifi],
}).hook(network, (self) => {
    const availableDevices = network.wifi.access_points;

    const children = [];

    for (let index = 0; index < availableDevices.length; index++) {
        const element = availableDevices[index];

        if (!element.active)
            children.push(
                WifiItem({
                    ssid: element.ssid,
                    strength: element.strength,
                })
            );
    }

    self.children = [
        connectedWifi,
        Widget.Scrollable({
            hscroll: 'never',
            vscroll: 'automatic',
            css: 'min-height:34.5rem;',
            child: Widget.Box({
                vertical: true,
                children: children,
            }),
        }),
    ];
});

globalThis.getNet = () => {
    console.log(network);
    console.log('----------');
    console.log(network.wifi);
    console.log('----------');
    console.log(network.wifi.scan());
    console.log('----------');
    console.log(network.wifi.access_points);
};

const menu = Widget.Box({
    vertical: true,
    children: [connectedWifiDetailsBox],
});

export default menu;

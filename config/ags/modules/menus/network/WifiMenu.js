import {
    TitleText,
    TitleTextRevealer2,
    truncateString,
} from '../../utils/helpers.js';

const network = await Service.import('network');

var allowRefresh = true;

const connectedWifiIcon = TitleText({
    titleClass: 'themes-buttons-icon',
    textClass: 'themes-buttons-icon',
    title: '',
    text: '',
    vertical: false,
    spacing: 20,
}).hook(network, (self) => {
    self.children[1].label = truncateString(network.wifi.ssid, 5);
    self.children[0].label = setConnectedWifiIcon(network);
});

const connectedWifi = Widget.Box({
    vertical: true,
    children: [
        TitleText({
            titleWidget: connectedWifiIcon,
            text: '',
            vertical: false,
            homogeneous: true,
            textYalign: 0.2,
            textXalign: 0.9,
        }).hook(network, (self) => {
            self.children[1].label = network.wifi.internet;
        }),
        TitleText({
            vertical: false,
            title: '',
            titleXalign: 0.5,
            spacing: 10,
            textWidget: Widget.Button({
                css: 'min-width: 4rem;',
                child: Widget.Label(''),
                className: 'icon-font',
                onClicked: (btn) => {
                    network.wifi.scan();
                    btn.child = Widget.Spinner({ visible: true });
                },
            }).hook(network, (btn) => {
                btn.child = Widget.Label('');
            }),
            titleCss: 'min-width: 14rem;',
            boxCss: 'margin-bottom:1rem;',
        }).hook(network, (self) => {
            if (
                network.wifi.internet === 'disconnected' ||
                network.wifi.internet === 'connecting'
            ) {
                self.label = '';
                return;
            }

            const selectedWifi = network.wifi.access_points.find(
                (network) => network.active
            ).bssid;
            self.children[0].label = `${selectedWifi}`;
        }),
    ],
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
    requiresPassword,
    titleClass = 'themes-buttons-icon',
    textClass = 'themes-buttons-icon',
}) => {
    const entryWidget = !requiresPassword
        ? { title: '' }
        : {
              titleWidget: Widget.Entry({
                  placeholder_text: 'Password',
                  visibility: false,
              }),
          };

    return TitleTextRevealer2({
        titleWidget: TitleText({
            titleClass: titleClass,
            textClass: textClass,
            title: setWifiIcon(strength),
            text: ssid,
            vertical: false,
            spacing: 20,
        }),
        textWidget: TitleText({
            vertical: false,
            spacing: 20,
            textWidget: Widget.Button({
                label: 'Connect',
                onClicked: (btn) => {
                    const password = !requiresPassword
                        ? null
                        : btn.get_parent().children[0].text;

                    network.wifi
                        .connectToAP(ssid, password)
                        .then((val) => {})
                        .catch((val) => {});

                    allowRefresh = true;
                },
            }),
            ...entryWidget,
        }),
        buttonClass: 'unset un-hover',
        revealerClass: 'unset',
        boxCss: 'margin-bottom:1rem;',
        onHover: null,
        onHoverLost: null,
        onClicked: (btn) => {
            btn.get_parent().children[1].reveal_child =
                !btn.get_parent().children[1].reveal_child;

            allowRefresh = !btn.get_parent().children[1].reveal_child;
        },
    });
};

const connectedWifiDetailsBox = Widget.Box({
    className: 'themes-box',
    vertical: true,
    children: [connectedWifi],
}).hook(network, (self) => {
    if (!allowRefresh) return;

    const availableDevices = network.wifi.access_points;

    const children = [];

    for (let index = 0; index < availableDevices.length; index++) {
        const element = availableDevices[index];

        if (!element.active && !element.hidden)
            children.push(
                WifiItem({
                    ssid: truncateString(element.ssid, 20),
                    strength: element.strength,
                    requiresPassword:
                        !element.saved && element.requiresPassword,
                })
            );
    }

    self.children = [
        connectedWifi,
        Widget.Separator({
            className: 'separator',
            vertical: false,
        }),
        Widget.Scrollable({
            hscroll: 'never',
            vscroll: 'automatic',
            css: 'min-height:31.8rem;',
            child: Widget.Box({
                vertical: true,
                children: [
                    Widget.Separator({
                        css: 'min-height:1rem;',
                        className: 'unset',
                        vertical: false,
                    }),
                    ...children,
                ],
            }),
        }),
    ];
});

const menu = Widget.Box({
    vertical: true,
    children: [connectedWifiDetailsBox],
});

export default menu;

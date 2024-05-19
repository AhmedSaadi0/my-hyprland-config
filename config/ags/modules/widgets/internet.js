import { Box, Label } from 'resource:///com/github/Aylur/ags/widget.js';
import { exec } from 'resource:///com/github/Aylur/ags/utils.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import settings from '../settings.js';

function convertToH(bytes) {
    let speed;
    let dim;
    let bits = bytes * 8;
    bits = bits / 10;

    if (bits < 1000) {
        bits = 0;
        speed = bits;
        dim = 'b/s';
    } else if (bits < 1000000) {
        speed = bits / 1000;
        dim = 'kb/s';
    } else if (bits < 1000000000) {
        speed = bits / 1000000;
        dim = 'mb/s';
    } else if (bits < 1000000000000) {
        speed = bits / 1000000000;
        dim = 'gb/s';
    } else {
        speed = parseFloat(bits);
        dim = 'b/s';
    }

    return Math.floor(speed + 0.5) + dim;
}

const TIMEOUT = 300;

const NetSpeedMeters = () => {
    let prevReceivedBytes = 0;
    let prevTransmittedBytes = 0;

    return Box().poll(settings.hardware.network.timeout, (box) => {
        const receivedBytes = exec('cat ' + settings.hardware.network.rx_path);
        const transmittedBytes = exec(
            'cat ' + settings.hardware.network.tx_path
        );

        const download = Label({
            justification: 'right',
            css: 'min-width: 60px',
        });
        const upload = Label({
            justification: 'right',
            css: 'min-width: 80px',
        });

        const downloadSpeed =
            (receivedBytes - prevReceivedBytes) /
            (settings.hardware.network.timeout /
                settings.hardware.network.interval);
        const uploadSpeed =
            (transmittedBytes - prevTransmittedBytes) /
            (settings.hardware.network.timeout /
                settings.hardware.network.interval);

        download.label = `${convertToH(downloadSpeed)} `;
        upload.label = `${convertToH(uploadSpeed)} `;

        prevReceivedBytes = receivedBytes;
        prevTransmittedBytes = transmittedBytes;

        box.children = [download, upload];

        box.show_all();
    });
};

export const NetworkInformation = () =>
    Box({
        className: 'internet-box small-shadow unset',
    }).hook(Network, (box) => {
        let internetLabel;

        const ssidLabel = Label({
            className: 'wifi-name-label unset',
            label: `${Network.wifi.ssid}`,
        });

        if (Network.wifi?.internet === 'disconnected') {
            internetLabel = '󰤮';
        } else if (Network.connectivity === 'limited') {
            internetLabel = '󰤩';
        } else if (Network.wifi?.strength > 85) {
            internetLabel = '󰤨';
        } else if (Network.wifi?.strength > 70) {
            internetLabel = '󰤥';
        } else if (Network.wifi?.strength > 50) {
            internetLabel = '󰤢';
        } else if (Network.wifi?.strength > 20) {
            internetLabel = '󰤟';
        } else {
            internetLabel = '󰤯';
        }

        const internetStatusLabel = Label({
            className: 'wifi-icon-strength unset',
            label: internetLabel,
        });

        box.children = [NetSpeedMeters(), ssidLabel, internetStatusLabel];

        box.show_all();
    });

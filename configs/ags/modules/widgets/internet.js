import { Box, Label } from 'resource:///com/github/Aylur/ags/widget.js';
import { exec } from 'resource:///com/github/Aylur/ags/utils.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';

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

  return Box().poll(TIMEOUT, (box) => {
    const receivedBytes = exec(
      'cat /sys/class/net/wlp0s20f3/statistics/rx_bytes'
    );
    const transmittedBytes = exec(
      'cat /sys/class/net/wlp0s20f3/statistics/tx_bytes'
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
      (receivedBytes - prevReceivedBytes) / (TIMEOUT / 1000);
    const uploadSpeed =
      (transmittedBytes - prevTransmittedBytes) / (TIMEOUT / 1000);

    download.label = `${convertToH(downloadSpeed)} `;
    upload.label = `${convertToH(uploadSpeed)} `;

    prevReceivedBytes = receivedBytes;
    prevTransmittedBytes = transmittedBytes;

    box.children = [
      download,
      upload,
      // Circular({progress:50})
    ];

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

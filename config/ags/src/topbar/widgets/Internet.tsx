import { bind } from 'astal';
import { networkSpeed } from '../../utils/system-usage';
import Network from 'gi://AstalNetwork';

const network = Network.get_default();

function formatSpeed(speed: number): string {
    if (speed >= 1024) {
        return `${(speed / 1024).toFixed(1).padStart(5, ' ')} MB/s`;
    }
    return `${speed.toFixed(0).padStart(5, ' ')} KB/s`;
}

export default function InternetWidget() {
    const download = bind(networkSpeed).as((value) => formatSpeed(value.rx));
    const upload = bind(networkSpeed).as((value) => formatSpeed(value.tx));

    return (
        <eventbox>
            <box className="topbar-network-box">
                <box>
                    <label
                        css="color: green;"
                        className="icon-font"
                        label="↓"
                    />
                    <label css="min-width: 70px">{download}</label>
                    <label css="color: red;" className="icon-font" label="↑" />
                    <label css="min-width: 70px">{upload}</label>
                </box>
                <label className="wifi-name-label">
                    {bind(network.wifi, 'ssid').as((val) => val)}
                </label>
                <label className="wifi-icon-strength">
                    {bind(network.wifi, 'strength').as((val) => {
                        if (val > 85) return '󰤨';
                        if (val > 70) return '󰤥';
                        if (val > 50) return '󰤢';
                        if (val > 20) return '󰤟';
                        return '󰤯';
                    })}
                </label>
            </box>
        </eventbox>
    );
}

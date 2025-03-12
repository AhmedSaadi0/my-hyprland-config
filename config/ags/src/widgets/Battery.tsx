import Battery from 'gi://AstalBattery';
import { bind } from 'astal';
import { CIRCULAR_PROGRESS_CONFIG } from '../utils/const';

const battery = Battery.get_default();

export default function BatteryWidget({
    progressClass = 'battery',
    buttonClassName = 'unset no-hover',
    labelClassName = 'battery-inner',
}) {
    const percentage = bind(battery, 'percentage');
    const charging = bind(battery, 'charging');
    // const powerSupply = bind(battery, 'power-supply');

    const batteryIcon = charging.as((val) => {
        const percent = percentage.get() * 100;
        if (val) {
            if (percent <= 10) return '󰢜';
            if (percent <= 20) return '󰂆';
            if (percent <= 30) return '󰂇';
            if (percent <= 40) return '󰂈';
            if (percent <= 50) return '󰢝';
            if (percent <= 60) return '󰂉';
            if (percent <= 70) return '󰢞';
            if (percent <= 80) return '󰂊';
            if (percent <= 90) return '󰂋';
            return '󰂅';
        } else {
            if (percent <= 10) return '󰁺';
            if (percent <= 20) return '󰁻';
            if (percent <= 30) return '󰁼';
            if (percent <= 40) return '󰁽';
            if (percent <= 50) return '󰁾';
            if (percent <= 60) return '󰁿';
            if (percent <= 70) return '󰂀';
            if (percent <= 80) return '󰂁';
            if (percent <= 90) return '󰂂';
            return '󰁹';
        }
    });
    return (
        <circularprogress
            className={progressClass}
            {...CIRCULAR_PROGRESS_CONFIG}
            value={percentage}
        >
            <button className={buttonClassName}>
                <label className={labelClassName} label={batteryIcon} />
            </button>
        </circularprogress>
    );
}

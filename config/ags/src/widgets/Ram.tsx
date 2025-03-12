import { bind } from 'astal';
import { CIRCULAR_PROGRESS_CONFIG } from '../utils/const';
import { ramUsage } from '../utils/system-usage';
import strings from '../utils/strings';

export default function RamWidget({
    progressClass = 'ram',
    buttonClassName = 'unset no-hover',
    labelClassName = 'ram-inner',
}) {
    const usage = bind(ramUsage).as((value) => (value / 100).toFixed(2));

    return (
        <circularprogress
            className={progressClass}
            {...CIRCULAR_PROGRESS_CONFIG}
            value={usage}
        >
            <button className={buttonClassName}>
                <label
                    className={labelClassName}
                    label=""
                    tooltipMarkup={bind(ramUsage).as(
                        (value) => `${strings.ramUsage}: ${value.toFixed(2)}%`
                    )}
                />
            </button>
        </circularprogress>
    );
}

import { bind } from 'astal';
import { CIRCULAR_PROGRESS_CONFIG } from '../utils/const';
import { temperature } from '../utils/temp';
import strings from '../utils/strings';

export default function TempWidget({
    progressClass = 'temp',
    buttonClassName = 'unset no-hover',
    labelClassName = 'temp-inner',
}) {
    const usage = bind(temperature).as((value) => (value / 100).toFixed(2));

    return (
        <circularprogress
            className={progressClass}
            value={usage}
            {...CIRCULAR_PROGRESS_CONFIG}
        >
            <button className={buttonClassName}>
                <label
                    className={labelClassName}
                    label=""
                    tooltipMarkup={bind(temperature).as(
                        (value) => `${strings.temp}: ${value.toFixed(2)}%`
                    )}
                />
            </button>
        </circularprogress>
    );
}

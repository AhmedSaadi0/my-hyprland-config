import { bind } from 'astal';
import { cpuUsage } from '../utils/system-usage';
import { CIRCULAR_PROGRESS_CONFIG } from '../utils/const';
import strings from '../utils/strings';

export default function CpuWidget({
    progressClass = 'cpu',
    buttonClassName = 'unset no-hover',
    labelClassName = 'cpu-inner',
}) {
    const usage = bind(cpuUsage).as((value) => (value / 100).toFixed(2));

    return (
        <circularprogress
            className={progressClass}
            value={usage}
            {...CIRCULAR_PROGRESS_CONFIG}
            startAt={0.41}
            endAt={0.1}
        >
            <button className={buttonClassName}>
                <label
                    className={labelClassName}
                    label=""
                    tooltipMarkup={bind(cpuUsage).as(
                        (value) => `${strings.cpuUsage}: ${value.toFixed(2)}%`
                    )}
                />
            </button>
        </circularprogress>
    );
}

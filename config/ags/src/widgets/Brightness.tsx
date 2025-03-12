import { CIRCULAR_PROGRESS_CONFIG } from '../utils/const';

export default function BrightnessWidget({
    progressClass = 'brightness',
    buttonClassName = 'unset no-hover',
    labelClassName = 'brightness-inner',
}) {
    return (
        <circularprogress
            className={progressClass}
            {...CIRCULAR_PROGRESS_CONFIG}
        >
            <button className={buttonClassName}>
                <label className={labelClassName} label="󰃠" />
            </button>
        </circularprogress>
    );
}

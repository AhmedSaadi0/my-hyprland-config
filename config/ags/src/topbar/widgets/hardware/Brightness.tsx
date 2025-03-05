import { CIRCULAR_PROGRESS_CONFIG } from '../../../utils/const';

export default function BrightnessWidget() {
    return (
        <box className="bar-hw-brightness-box">
            <circularprogress
                className="brightness"
                {...CIRCULAR_PROGRESS_CONFIG}
            >
                <button className="unset no-hover">
                    <label className="brightness-inner" label="󰃠" />
                </button>
            </circularprogress>
        </box>
    );
}

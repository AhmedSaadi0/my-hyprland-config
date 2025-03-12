import Wp from 'gi://AstalWp';
import { CIRCULAR_PROGRESS_CONFIG } from '../utils/const';
// import { bind } from 'astal';

const audio = Wp.get_default().audio;

export default function AudioWidget({
    progressClass = 'volume',
    buttonClassName = 'unset no-hover',
    labelClassName = 'volume-inner',
}) {
    print(audio.devices);
    print(audio.speakers);
    print(audio.default_speaker.volume);

    // const usage = bind(audio.default_speaker.volume).as((value) =>
    //     (value / 100).toFixed(2)
    // );

    return (
        <circularprogress
            className={progressClass}
            // value={usage}
            {...CIRCULAR_PROGRESS_CONFIG}
            startAt={0.41}
            endAt={0.1}
        >
            <button className={buttonClassName}>
                <label className={labelClassName} label="" />
            </button>
        </circularprogress>
    );
}

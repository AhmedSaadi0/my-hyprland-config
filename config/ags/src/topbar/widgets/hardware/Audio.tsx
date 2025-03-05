import { CIRCULAR_PROGRESS_CONFIG } from '../../../utils/const';

export default function AudioWidget() {
    return (
        <box>
            <circularprogress className="volume" {...CIRCULAR_PROGRESS_CONFIG}>
                <button className="unset no-hover">
                    <label className="volume-inner" label="" />
                </button>
            </circularprogress>
        </box>
    );
}

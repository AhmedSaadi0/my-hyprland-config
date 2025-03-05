import { CIRCULAR_PROGRESS_CONFIG } from '../../../utils/const';

export default function TempWidget() {
    return (
        <box className="bar-hw-temp-box" poll={30000}>
            <circularprogress className="temp" {...CIRCULAR_PROGRESS_CONFIG}>
                <button className="unset no-hover">
                    <label className="temp-inner" label="" />
                </button>
            </circularprogress>
        </box>
    );
}

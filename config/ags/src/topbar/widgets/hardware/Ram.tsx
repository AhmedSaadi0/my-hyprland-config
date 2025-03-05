import { CIRCULAR_PROGRESS_CONFIG } from '../../../utils/const';

export default function RamWidget() {
    return (
        <box className="bar-hw-ram-box" poll={30000}>
            <circularprogress className="ram" {...CIRCULAR_PROGRESS_CONFIG}>
                <button className="unset no-hover">
                    <label className="ram-inner" label="" />
                </button>
            </circularprogress>
        </box>
    );
}

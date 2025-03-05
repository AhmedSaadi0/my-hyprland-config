import { bind } from 'astal';
import { CIRCULAR_PROGRESS_CONFIG } from '../../../utils/const';
import { cpuUsage } from '../../../utils/cpu';

export default function CpuWidget() {
    const usage = bind(cpuUsage).as((value) => {
        const val = value / 100;
        return val;
    });

    return (
        <circularprogress
            className="cpu"
            value={usage}
            {...CIRCULAR_PROGRESS_CONFIG}
        >
            <button className="unset no-hover">
                <label className="cpu-inner" label="" />
            </button>
        </circularprogress>
    );
}

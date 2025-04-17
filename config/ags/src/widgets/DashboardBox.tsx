import { Widget } from '../../types/@girs/gtk-3.0/gtk-3.0.cjs';
import { TitleText } from './TitleText';

export default function DashboardBox({
    icon,
    text,
    widget: widget,
}: {
    icon: string;
    text: string;
    widget: Widget;
}) {
    return (
        <box
            css="margin-bottom: 1rem;"
            className="left-menu-insider-box"
            vertical={true}
        >
            <TitleText
                title={icon}
                text={text}
                titleClass="themes-card-icon"
                textClass="themes-card-title"
                vertical={false}
                buttonClass="unset"
            />
            {widget}
        </box>
    );
}

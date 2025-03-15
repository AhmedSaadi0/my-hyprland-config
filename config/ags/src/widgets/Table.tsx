import { Binding } from 'astal';
import { Gtk } from 'astal/gtk3';

interface TableProps {
    header: JSX.Element; // مكون الهيدر
    rows: Binding<JSX.Element[]> | Gtk.Widget[];
    boxClass?: string; // كلاس CSS للجدول
    headerClass?: string; // كلاس CSS للهيدر
    spacing?: number; // التباعد بين العناصر
    vertical?: boolean; // هل يكون الجدول عموديًا؟
    homogeneous?: boolean; // هل تكون العناصر بنفس الحجم؟
}

export const Table = ({
    header,
    rows,
    boxClass = '',
    headerClass = '',
    spacing = 5,
    vertical = true,
    homogeneous = false,
}: TableProps) => {
    return (
        <box
            className={boxClass}
            vertical={vertical}
            homogeneous={homogeneous}
            spacing={spacing}
        >
            {/* الهيدر */}
            <box className={headerClass}>{header}</box>

            {/* الصفوف */}
            {rows}
        </box>
    );
};

interface TableProps {
    header: JSX.Element; // مكون الهيدر
    rows: JSX.Element[]; // قائمة الصفوف
    boxClass?: string; // كلاس CSS للجدول
    headerClass?: string; // كلاس CSS للهيدر
    rowClass?: string; // كلاس CSS لكل صف
    spacing?: number; // التباعد بين العناصر
    vertical?: boolean; // هل يكون الجدول عموديًا؟
    homogeneous?: boolean; // هل تكون العناصر بنفس الحجم؟
}

export const Table = ({
    header,
    rows,
    boxClass = '',
    headerClass = '',
    rowClass = '',
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
            {/* {rows.map((row, index) => ( */}
            {/*     <box key={`row-${index}`} className={rowClass}> */}
            {/*         {row} */}
            {/*     </box> */}
            {/* ))} */}
        </box>
    );
};

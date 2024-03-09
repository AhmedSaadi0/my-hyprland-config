import { Widget } from '../utils/imports.js';

const createNestedCircles = ({
    child = null,
    innerCircle1Css = '',
    innerCircle2Css = '',
    innerCircle3Css = '',
    innerCircle4Css = '',
    innerCircle5Css = '',
    innerCircle6Css = '',
    outerCircle1Css = '',
    outerCircle2Css = '',
    outerCircle3Css = '',
    outerCircle4Css = '',
}) => {
    const innerCircle1 = Widget.CircularProgress({
        css: `
            font-size: 1rem;
            min-width: 6rem;
            min-height: 6rem;
        `,
        className: innerCircle1Css,
        child: child,
        startAt: 0.25,
        endAt: 0.5,
        // inverted: true
    });

    const innerCircle2 = Widget.CircularProgress({
        css: `
            font-size: 1rem;
            min-width: 8.2rem;
            min-height: 8.2rem;
        `,
        className: innerCircle2Css,
        startAt: 0.25,
        endAt: 0.5,
    });

    const innerCircle3 = Widget.CircularProgress({
        css: `
            font-size: 1.08rem;
            min-height: 10.5rem;
            min-width: 10.5rem;
        `,
        className: innerCircle3Css,
        startAt: 0.25,
        endAt: 0.5,
    });

    const innerCircle4 = Widget.CircularProgress({
        css: `
            font-size: 1rem;
            min-width: 6rem;
            min-height: 6rem;
        `,
        className: innerCircle4Css,
        startAt: 0.75,
        endAt: 1,
    });

    const innerCircle5 = Widget.CircularProgress({
        css: `
            font-size: 1rem;
            min-width: 8.2rem;
            min-height: 8.2rem;
        `,
        className: innerCircle5Css,
        startAt: 0.75,
        endAt: 1,
    });

    const innerCircle6 = Widget.CircularProgress({
        css: `
            font-size: 1.08rem;
            min-height: 10.5rem;
            min-width: 10.5rem;
        `,
        className: innerCircle6Css,
        startAt: 0.75,
        endAt: 1,
    });

    const outerCircle1 = Widget.CircularProgress({
        css: `
            font-size: 0.3rem;
            min-height: 11.7rem;
            min-width: 11.7rem;
        `,
        className: outerCircle1Css,
        startAt: 0.25,
        endAt: 1,
    });

    const outerCircle2 = Widget.CircularProgress({
        css: `
            font-size: 0.3rem;
            min-height: 12.65rem;
            min-width: 12.65rem;
        `,
        className: outerCircle2Css,
        startAt: 0.25,
        endAt: 1,
    });

    const outerCircle3 = Widget.CircularProgress({
        css: `
            font-size: 0.3rem;
            min-height: 14rem;
            min-width: 14rem;
        `,
        className: outerCircle3Css,
        startAt: 0.75,
        endAt: 0.5,
    });

    const outerCircle4 = Widget.CircularProgress({
        css: `
            font-size: 0.3rem;
            min-height: 14.9rem;
            min-width: 14.9rem;
        `,
        className: outerCircle4Css,
        startAt: 0.75,
        endAt: 0.5,
    });

    return {
        innerCircle1: innerCircle1,
        innerCircle2: innerCircle2,
        innerCircle3: innerCircle3,
        innerCircle4: innerCircle4,
        innerCircle5: innerCircle5,
        innerCircle6: innerCircle6,
        outerCircle1: outerCircle1,
        outerCircle2: outerCircle2,
        outerCircle3: outerCircle3,
        outerCircle4: outerCircle4,
    };
};

export default createNestedCircles;

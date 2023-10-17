import MusicPLayer from "../MusicPLayer.js";
import { TitleText } from "../../utils/helpers.js";

import { Box, Icon, Label, EventBox, Button, Revealer } from 'resource:///com/github/Aylur/ags/widget.js';

const RowOne = () => {

    const iconImage = Icon({
        icon: "/home/ahmed/.config/ags/images/profile-modified.png",
        size: 70,
        className: "user-icon",
    })

    const weatherIcon = Label({
        label: "",
        className: "weather-icon",
    })

    return Box({
        className: "row-one",
        children: [
            iconImage,
            TitleText({
                title: "اليوم",
                titleClass: "row-title",
                text: "سماء صافية | 9C",
                textClass: "row-text",
                boxClass: "row-box",
            }),
            weatherIcon,
        ]
    })
}

const Insider = () => {

    const label = Label({
        label: "",
        className: "insider-weather-icon"
    })

    return Box({
        className: "insider-box",
        vertical: true,
        homogeneous: true,
        children: [
            label,
            TitleText({
                title: "سبت",
                titleClass: "",
                text: "15C",
                textClass: "",
                boxClass: "",
            })
        ]
    })
}

const RowTwo = () => {
    return Box({
        className: "row-two",
        spacing: 15,
        homogeneous: false,
        children: [
            Insider(),
            Insider(),
            Insider(),
            Insider(),
        ]
    })
}

const RowThree = () => {
    return Box({
        className: "row-three",
        spacing: 15,
        homogeneous: false,
        children: [
            Label({
                label: "   🎜   مشغل الموسيقى",
            }),
            Label({
                // style:`
                //     margin-top: -0.6rem;
                // `,
                label: "ـــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ",
            }),
            MusicPLayer(),
        ]
    })
}

export default widget => Box({
    className: "father-box",
    vertical: true,
    children: [
        RowOne(),
        RowTwo(),
        RowThree(),
    ]

})
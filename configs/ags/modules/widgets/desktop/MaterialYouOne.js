import MusicPlayer from "../MusicPLayer.js";
import { TitleText } from "../../utils/helpers.js";
import WeatherService from '../../services/WeatherService.js';
import { Box, Icon, Label } from 'resource:///com/github/Aylur/ags/widget.js';

const iconImage = Icon({
    icon: "/home/ahmed/.config/ags/images/profile-modified.png",
    size: 70,
    className: "user-icon",
})

const weatherIcon = Label({
    label: "",
    className: "weather-wd-icon",
})


const RowOne = () => Box({
    className: "weather-wd-row-one",
    children: [
        iconImage,
        // tt,
        weatherIcon,
    ],
    connections: [[WeatherService, self => {
        const tt = TitleText({
            title: "اليوم",
            titleClass: "weather-wd-title",
            // text: "سماء صافية | 9C",
            text: WeatherService.arValue,
            textClass: "weather-wd-text",
            boxClass: "weather-wd-title-text-box",
            titleXalign: 1,
            textXalign: 1,
        });

        weatherIcon.label = WeatherService.weatherCode;

        self.children = [
            weatherIcon,
            tt,
            iconImage,
        ]
    }]]
});

const Insider = ({
    icon,
    title,
    text,
}) => {

    const label = Label({
        label: icon,
        className: "weather-wd-day-icon"
    })

    return Box({
        className: "weather-wd-day-box",
        vertical: true,
        homogeneous: true,
        children: [
            label,
            TitleText({
                title: title,
                titleClass: "",
                text: text,
                textClass: "",
                boxClass: "",
            })
        ]
    })
}

const RowTwo = () => {
    return Box({
        className: "weather-wd-row-two",
        spacing: 15,
        homogeneous: false,
        children: [
        ],
        connections: [[WeatherService, self => {
            self.children = [
                Insider({
                    icon: WeatherService.weatherCode1,
                    title: WeatherService.avgTempC1,
                    text: WeatherService.weatherTime1,
                }),
                Insider({
                    icon: WeatherService.weatherCode2,
                    title: WeatherService.avgTempC2,
                    text: WeatherService.weatherTime2,
                }),
                Insider({
                    icon: WeatherService.weatherCode3,
                    title: WeatherService.avgTempC3,
                    text: WeatherService.weatherTime3,
                }),

            ]
        }
        ]]
    })
}

const RowThree = () => {
    return Box({
        className: "wd-row-three",
        spacing: 15,
        homogeneous: false,
        children: [
            Label({
                label: "   🎜   مشغل الموسيقى",
            }),
            Label({
                label: "ـــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ",
            }),
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
        Box({
            className: "music-father-box shadow",
            children: [
                MusicPlayer(),
            ]
        })
    ]

})
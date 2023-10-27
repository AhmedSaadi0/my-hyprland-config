import MusicPlayer from "../MusicPLayer.js";
import { TitleText } from "../../utils/helpers.js";
import WeatherService from '../../services/WeatherService.js';
import { Widget } from "../../utils/imports.js";

const iconImage = Widget.Icon({
    icon: "/home/ahmed/.config/ags/images/profile-modified.png",
    size: 70,
    className: "my-wd-user-icon",
})

const weatherIcon = Widget.Label({
    label: "",
    className: "my-weather-wd-icon",
})

const RowOne = () => Widget.Box({
    className: "weather-wd-row-one shadow",
    children: [
    ],
    connections: [[WeatherService, self => {
        const tt = TitleText({
            title: "اليوم",
            // titleClass: "weather-wd-title",
            text: WeatherService.arValue,
            textClass: "my-weather-wd-text",
            boxClass: "my-weather-wd-title-text-box",
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

    const label = Widget.Label({
        label: icon,
        className: "my-weather-wd-day-icon"
    })

    return Widget.Box({
        className: "my-weather-wd-day-box",
        vertical: true,
        homogeneous: true,
        children: [
            label,
            TitleText({
                title: title,
                titleClass: "my-wd-weather-day-name",
                text: text,
                textClass: "my-wd-weather-day-text",
                boxClass: "",
            })
        ]
    })
}

const RowTwo = () => {
    return Widget.Box({
        className: "my-weather-wd-row-two shadow",
        spacing: 16,
        homogeneous: false,
        children: [
        ],
        connections: [[WeatherService, self => {
            self.children = [
                Insider({
                    icon: WeatherService.weatherCode1,
                    title: "اليوم",
                    text: WeatherService.avgTempC1,
                }),
                Insider({
                    icon: WeatherService.weatherCode2,
                    title: "غدا",
                    text: WeatherService.avgTempC2,
                }),
                Insider({
                    icon: WeatherService.weatherCode3,
                    title: "ب غدا",
                    text: WeatherService.avgTempC3,
                }),
                Insider({
                    icon: WeatherService.weatherCode3,
                    title: "ب يومين",
                    text: WeatherService.avgTempC3,
                }),

            ]
        }
        ]]
    })
}

const DesktopWidget = () => Widget.Box({
    vertical: true,
    children: [
        RowOne(),
        RowTwo(),
        MusicPlayer("my-desktop-music-box shadow"),
    ]
})

const FWidget = () => Widget.Window({
    name: `desktop_material_you_widget`,
    margin: [60, 60],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['top', "right"],
    child: DesktopWidget(),
})

const materialWidget = FWidget();

globalThis.ShowMYWidget = () => materialWidget.visible = true;
globalThis.HideMYWidget = () => materialWidget.visible = false;

export default materialWidget;
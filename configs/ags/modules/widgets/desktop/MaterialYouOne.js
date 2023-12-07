import MusicPlayer from "../MusicPLayer.js";
import WeatherService from '../../services/WeatherService.js';
import FuzzyClock from "../FuzzyClock.js";
import Saying from "../Saying.js";
import { TitleText } from "../../utils/helpers.js";
import { Utils, Widget } from "../../utils/imports.js";

const iconImage = Widget.Icon({
    icon: `/home/${Utils.USER}/.config/ags/images/image.png`,
    size: 70,
    className: "my-wd-user-icon",
})

const weatherIcon = Widget.Label({
    label: "",
    className: "my-weather-wd-icon",
})

const RowOne = () => Widget.Box({
    className: "weather-wd-row-one small-shadow",
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
        className: "my-weather-wd-row-two small-shadow",
        spacing: 50,
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
                // Insider({
                //     icon: WeatherService.weatherCode4,
                //     title: "ب يومين",
                //     text: WeatherService.avgTempC4,
                // }),

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
        // FuzzyClock("my-fuzzy-clock-box small-shadow"),
        MusicPlayer("my-desktop-music-box small-shadow"),
        // Saying("saying-wd-label small-shadow"),
    ]
})

const DesktopWidget2 = () => Widget.Box({
    vertical: true,
    children: [
        FuzzyClock("my-fuzzy-clock-box small-shadow"),
        Saying("saying-wd-label small-shadow"),
    ]
})

const FWidget = () => Widget.Window({
    name: `desktop_material_you_widget`,
    margins: [60, 60],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['top', "left"],
    child: DesktopWidget(),
})

const FWidget2 = () => Widget.Window({
    name: `desktop_material_you_widget_2`,
    margins: [60, 60],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['top', "right"],
    child: DesktopWidget2(),
})

const materialWidget = FWidget();
const materialWidget2 = FWidget2();

globalThis.ShowMYWidget = () => {
    materialWidget.visible = true
    materialWidget2.visible = true
};
globalThis.HideMYWidget = () => {
    materialWidget.visible = false
    materialWidget2.visible = false
};

export default materialWidget;
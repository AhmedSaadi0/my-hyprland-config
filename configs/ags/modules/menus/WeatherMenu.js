import weatherService from '../services/WeatherService.js';
import { local, TitleText } from '../utils/helpers.js';
import { Widget } from '../utils/imports.js';

const createWeatherDay = () => {
    const time = Widget.Label({
        className: "weather-menu-today-time",
    });

    const tempC = Widget.Label({
        className: "weather-menu-today-temp",
    });

    const weather = Widget.Label({
        className: "weather-menu-today-weather",
        max_width_chars: 10,
        justification: 'left',
        truncate: 'end',
    });

    return Widget.Box({
        vertical: true,
        className: "weather-menu-today-box",
        children: [
            time,
            tempC,
            weather,
        ]
    });
}

const MenuRevealer = () => {

    const weatherIcon = Widget.Label({
        className: "weather-menu-icon",
    });

    const weatherCity = Widget.Label({
        xalign: 0,
        className: "weather-menu-city",
    });

    const weatherValue = Widget.Label({
        xalign: 0,
        className: "weather-menu-value",
    });

    const sunrise = TitleText({
        titleClass: "weather-menu-sunrise",
        textClass: "weather-menu-sunrise-icon",
        vertical: false,
    });

    const sunset = TitleText({
        titleClass: "weather-menu-sunset",
        textClass: "weather-menu-sunset-icon",
        vertical: false,
    });

    const latestUpdate = Widget.Button({
        className: "weather-menu-latest-update",
        onClicked: () => {
            weatherService.getWeather();
            latestUpdate.label = " ... "
        }
    });

    const feelsLike = Widget.Label({
        xalign: 0,
        className: "weather-menu-feels-like",
    });

    const humidity = Widget.Label({
        xalign: 0,
        className: "weather-menu-humidity",
    });

    const pressure = Widget.Label({
        xalign: 0,
        className: "weather-menu-pressure",
    });

    const wind = Widget.Label({
        xalign: 0,
        className: "weather-menu-wind",
    });

    const clouds = Widget.Label({
        xalign: 0,
        className: "weather-menu-clouds",
    });

    const minAndMax = Widget.Label({
        xalign: 0,
        className: "weather-menu-min-max",
    });

    const generalInformation = Widget.Box({
        vertical: true,
        className: "weather-menu-general-information-box",
        children: [
            weatherCity,
            weatherValue,
            Widget.Box({
                homogeneous: true,
                children: [
                    sunrise,
                    sunset,
                    latestUpdate
                ]
            })
        ]
    });

    const detailedInformation = Widget.Box({
        vertical: true,
        className: "weather-menu-detail-box",
        children: [
            feelsLike,
            humidity,
            pressure,
            wind,
            clouds,
            minAndMax
        ]
    });

    const rowOne = Widget.Box({
        children: [
            weatherIcon,
            generalInformation,
            detailedInformation
        ]
    });

    const today1 = createWeatherDay();
    const today2 = createWeatherDay();
    const today3 = createWeatherDay();
    const today4 = createWeatherDay();

    const rowTwo = Widget.Box({
        className: "weather-row-two",
        homogeneous: true,
        children: [
            today1,
            today2,
            today3,
            today4,
        ]
    });

    return Widget.Revealer({
        transition: "slide_down",
        child: Widget.Box({
            className: "weather-menu-box",
            vertical: true,
            children: [
                rowOne,
                rowTwo
            ],
        }).hook(weatherService, box => {
            weatherIcon.label = weatherService.weatherCode;
            weatherValue.label = `${weatherService.arValue}, ${weatherService.tempC} C°`;
            weatherCity.label = weatherService.areaName;

            sunrise.children[0].label = weatherService.sunrise;
            sunrise.children[1].label = ``;

            sunset.children[0].label = weatherService.sunset;
            sunset.children[1].label = ``;

            latestUpdate.label = ` ${weatherService.observation_time}`;

            feelsLike.label = `شعور وكانة : ${weatherService.feelsLike} C°`;
            humidity.label = `الرطوبة : ${weatherService.humidity}%`;
            pressure.label = `الضغط : ${weatherService.pressure}`;
            wind.label = `الرياح : ${weatherService.windspeedKmph}`;
            clouds.label = `السحب : ${weatherService.cloudcover}`;
            minAndMax.label = `الصغرى والعلياء : ${weatherService.minTempC} - ${weatherService.maxTempC}`

            today1.children[0].label = weatherService.hourly.hour1.time;
            today1.children[1].label = `${weatherService.hourly.hour1.weatherCode} ${weatherService.hourly.hour1.tempC} C°`;
            today1.children[2].label = weatherService.hourly.hour1.lang_ar;

            today2.children[0].label = weatherService.hourly.hour2.time;
            today2.children[1].label = `${weatherService.hourly.hour2.weatherCode} ${weatherService.hourly.hour2.tempC} C°`;
            today2.children[2].label = weatherService.hourly.hour2.lang_ar;

            today3.children[0].label = weatherService.hourly.hour3.time;
            today3.children[1].label = `${weatherService.hourly.hour3.weatherCode} ${weatherService.hourly.hour3.tempC} C°`;
            today3.children[2].label = weatherService.hourly.hour3.lang_ar;

            today4.children[0].label = weatherService.hourly.hour4.time;
            today4.children[1].label = `${weatherService.hourly.hour4.weatherCode} ${weatherService.hourly.hour4.tempC} C°`;
            today4.children[2].label = weatherService.hourly.hour4.lang_ar;

        }),
    })
}

const menuRevealer = MenuRevealer();

export const WeatherMenu = () => Widget.Window({
    name: `weather_menu`,
    margins: [6, 210],
    anchor: ['top', local === "RTL" ? "left" : "right"],
    child: Widget.Box({
        css: `
            min-height: 2px;
            min-width: 2px;
        `,
        children: [
            menuRevealer,
        ],
    })
});

globalThis.showWeatherMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild
};

import { TitleText } from '../../utils/helpers.js';
import weatherService from '../../services/WeatherService.js';
import settings from '../../settings.js';
import strings from '../../strings.js';

const WeatherCard = ({ icon = '', title = '', text = '' }) => {
    const _icon = Widget.Label({
        className: 'weather-card-icon',
        label: icon,
    });

    const titleText = TitleText({
        title: title,
        text: text,
        spacing: 10,
        titleXalign: 0,
        textXalign: 0,
        // titleYalign: 0.2,
        // textYalign: 0.8,
        titleClass: 'weather-card-title',
        textClass: 'weather-card-text',
    });

    return Widget.Box({
        className: 'weather-card',
        spacing: 15,
        children: [_icon, titleText],
    });
};

const weatherLocation = Widget.Label({
    className: 'weather-city-name',
    label: '',
    xalign: 0,
});

const temperatureAndFeelsLike = TitleText({
    vertical: false,
    title: '',
    text: '',
    titleClass: 'weather-temperature',
    textClass: 'weather-feels-like',
    textYalign: 1,
});

const icon = Widget.Label({
    className: 'weather-icon',
    label: '',
});

const weatherDetails = Widget.Box({
    className: 'weather-details',
    children: [temperatureAndFeelsLike, icon],
});

const weatherHeaderCard = Widget.Box({
    vertical: true,
    className: 'weather-header-card',
    children: [weatherLocation, weatherDetails],
}).hook(weatherService, (box) => {
    weatherLocation.label = `${weatherService.areaName}, ${settings.prayerTimes.country}`;
    temperatureAndFeelsLike.children[0].label = `${weatherService.tempC}°`;
    temperatureAndFeelsLike.children[1].label = `${strings.feelsLike} ${weatherService.feelsLike}°`;

    icon.label = weatherService.weatherCode;
});

const windSpeed = WeatherCard({ icon: '󰖝', title: strings.wind }).hook(
    weatherService,
    (box) => {
        box.children[1].children[1].label = weatherService.windspeedKmph;
    }
);

const pressure = WeatherCard({ icon: '', title: strings.pressure }).hook(
    weatherService,
    (box) => {
        box.children[1].children[1].label = weatherService.pressure;
    }
);

const humidity = WeatherCard({ icon: '', title: strings.humidity }).hook(
    weatherService,
    (box) => {
        box.children[1].children[1].label = weatherService.humidity;
    }
);

const cloudcover = WeatherCard({ icon: '', title: strings.clouds }).hook(
    weatherService,
    (box) => {
        box.children[1].children[1].label = weatherService.cloudcover;
    }
);

const maxTemperature = WeatherCard({
    icon: '',
    title: strings.maxTemp,
}).hook(weatherService, (box) => {
    box.children[1].children[1].label = weatherService.maxTempC;
});

const minTemperature = WeatherCard({
    icon: '',
    title: strings.minTemp,
}).hook(weatherService, (box) => {
    box.children[1].children[1].label = weatherService.minTempC;
});

const sunrise = WeatherCard({ icon: '', title: strings.sunrise }).hook(
    weatherService,
    (box) => {
        box.children[1].children[1].label = weatherService.sunrise;
    }
);

const sunset = WeatherCard({ icon: '', title: strings.sunset }).hook(
    weatherService,
    (box) => {
        box.children[1].children[1].label = weatherService.sunset;
    }
);

const rowOne = Widget.Box({
    className: 'weather-row',
    children: [maxTemperature, minTemperature],
});

const rowFour = Widget.Box({
    className: 'weather-row',
    children: [sunrise, sunset],
});

const rowTwo = Widget.Box({
    className: 'weather-row',
    children: [windSpeed, pressure],
});

const rowThree = Widget.Box({
    className: 'weather-row',
    children: [humidity, cloudcover],
});

export default Widget.Box({
    vertical: true,
    children: [weatherHeaderCard, rowOne, rowTwo, rowThree, rowFour],
});

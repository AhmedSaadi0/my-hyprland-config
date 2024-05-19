// import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
// import Service from 'resource:///com/github/Aylur/ags/service.js';
import settings from '../settings.js';
import { notify } from '../utils/helpers.js';
import { Service, Utils } from '../utils/imports.js';

class WeatherService extends Service {
    static {
        Service.register(
            this,
            {},
            {
                // TODAY
                arValue: ['string', 'r'],
                weatherCode: ['string', 'r'],
                maxTempC: ['float', 'r'],
                minTempC: ['float', 'r'],

                feelsLike: ['float', 'r'],
                tempC: ['float', 'r'],
                pressure: ['float', 'r'],
                windspeedKmph: ['float', 'r'],
                humidity: ['float', 'r'],
                cloudcover: ['float', 'r'],

                observation_time: ['string', 'r'],
                areaName: ['string', 'r'],

                sunrise: ['string', 'r'],
                sunset: ['string', 'r'],
                moonrise: ['string', 'r'],
                moonset: ['string', 'r'],

                // HOURS
                avgTempC1: ['string', 'r'],
                weatherCode1: ['string', 'r'],
                weatherTime1: ['string', 'r'],

                avgTempC2: ['string', 'r'],
                weatherCode2: ['string', 'r'],
                weatherTime2: ['string', 'r'],

                avgTempC3: ['string', 'r'],
                weatherCode3: ['string', 'r'],
                weatherTime3: ['string', 'r'],

                hourly: ['dictionary', 'r'],

                // 'avgTempC4': ['string', 'r'],
                // 'weatherCode4': ['string', 'r'],
                // 'weatherTime4': ['string', 'r'],
            }
        );
    }

    coldWeatherWarned = false;
    hotWeatherWarned = false;

    constructor() {
        super();
        this.state = {};
        this.initWeather();
    }

    initWeather() {
        Utils.interval(900000, () => {
            this.getWeather();
        });
    }

    getWeather() {
        Utils.execAsync([
            'curl',
            `${settings.weather.language}.wttr.in/${settings.weather.location}?format=${settings.weather.format}`,
        ])
            .then((val) => {
                const jsonData = JSON.parse(val);
                this.state = jsonData;
                this.checkColdWeather();
                this.emit('changed');
            })
            .catch(() => {
                const source = setTimeout(() => {
                    this.getWeather();
                    source.destroy();
                    this.checkColdWeather();
                }, 300000);
            });
    }

    checkColdWeather() {
        if (parseInt(this.minTempC) <= 7 && !this.coldWeatherWarned) {
            notify({
                tonePath: settings.assets.audio.cold_weather,
                title: 'طقس بارد !',
                message: `درجة الحرارة الصغرى اليوم ${this.minTempC}°`,
                icon: settings.assets.icons.cold_weather,
                priority: 'critical',
            });
            this.coldWeatherWarned = true;
        } else if (parseInt(this.maxTempC) > 30 && !this.hotWeatherWarned) {
            notify({
                tonePath: settings.assets.audio.cold_weather,
                title: 'طقس حار !',
                message: `درجة الحرارة الكبرى اليوم ${this.maxTempC}°`,
                icon: settings.assets.icons.hot_weather,
            });
            this.hotWeatherWarned = true;
        }
    }

    isDay() {
        const sunriseTime = this.sunrise;
        const sunsetTime = this.sunset;

        const currentTime = new Date();
        const sunrise = new Date();
        const sunset = new Date();

        const sunriseComponents = sunriseTime.split(' ')[0].split(':');
        const sunriseHour = Number(sunriseComponents[0]);
        const sunriseMinute = Number(sunriseComponents[1]);
        const sunrisePeriod = sunriseTime.split(' ')[1];

        const sunsetComponents = sunsetTime.split(' ')[0].split(':');
        const sunsetHour = Number(sunsetComponents[0]);
        const sunsetMinute = Number(sunsetComponents[1]);
        const sunsetPeriod = sunsetTime.split(' ')[1];

        sunrise.setHours(
            sunriseHour +
                (sunrisePeriod === 'PM' && sunriseHour !== 12 ? 12 : 0)
        );
        sunrise.setMinutes(sunriseMinute);

        sunset.setHours(
            sunsetHour + (sunsetPeriod === 'PM' && sunsetHour !== 12 ? 12 : 0)
        );
        sunset.setMinutes(sunsetMinute);

        return currentTime > sunrise && currentTime < sunset;
    }

    get arValue() {
        try {
            return this.state?.current_condition?.[0]?.lang_ar[0].value;
        } catch (TypeError) {
            return (
                this.state?.current_condition?.[0]?.weatherDesc?.[0]?.value ||
                ''
            );
        }
    }

    get weatherCode() {
        const weatherCode = this.state?.current_condition?.[0]?.weatherCode;
        if (this.isDay()) {
            return sun_icon_dic[weatherCode] || '';
        } else {
            return moon_icon_dic[weatherCode] || '';
        }
    }

    get maxTempC() {
        return this.state?.weather?.[0]?.maxtempC || '';
    }

    get minTempC() {
        return this.state?.weather?.[0]?.mintempC || '';
    }

    get tempC() {
        return this.state?.current_condition?.[0]?.temp_C || '';
    }

    get feelsLike() {
        return this.state?.current_condition?.[0].FeelsLikeC || '';
    }

    get pressure() {
        return this.state?.current_condition?.[0].pressure || '';
    }

    get windspeedKmph() {
        return this.state?.current_condition?.[0].windspeedKmph || '';
    }

    get humidity() {
        return this.state?.current_condition?.[0].humidity || '';
    }

    get cloudcover() {
        return this.state?.current_condition?.[0].cloudcover || '';
    }

    get observation_time() {
        return this.state?.current_condition?.[0].observation_time || '';
    }

    get areaName() {
        return this.state?.nearest_area?.[0].areaName[0].value || '';
    }

    get sunrise() {
        return this.state?.weather?.[0].astronomy[0].sunrise || '18:00';
    }

    get sunset() {
        return this.state?.weather?.[0].astronomy[0].sunset || '05:00';
    }

    get moonrise() {
        return this.state?.weather?.[0].astronomy[0].moonrise || '';
    }

    get moonset() {
        return this.state?.weather?.[0].astronomy[0].moonset || '';
    }

    // -------------------------------------------
    get avgTempC1() {
        return `${this.state?.weather?.[0]?.avgtempC || ''} C°`;
        // return `${this.state?.current_condition?.temp_C || ''} C°`;
    }

    get weatherCode1() {
        const weatherCode = this.state?.weather?.[0]?.hourly?.[4]?.weatherCode;
        if (this.isDay()) {
            return sun_icon_dic[weatherCode] || '';
        } else {
            return moon_icon_dic[weatherCode] || '';
        }
    }

    get weatherTime1() {
        return 'اليوم';
    }

    // -------------------------------------------
    get avgTempC2() {
        return `${this.state?.weather?.[1]?.avgtempC || ''} C°`;
    }

    get weatherCode2() {
        const weatherCode = this.state?.weather?.[1]?.hourly?.[4]?.weatherCode;
        if (this.isDay()) {
            return sun_icon_dic[weatherCode] || '';
        } else {
            return moon_icon_dic[weatherCode] || '';
        }
    }

    get weatherTime2() {
        return 'غداً';
    }

    // -------------------------------------------
    get avgTempC3() {
        return `${this.state?.weather?.[2]?.avgtempC || ''} C°`;
    }

    get weatherCode3() {
        const weatherCode = this.state?.weather?.[2]?.hourly?.[4]?.weatherCode;
        if (this.isDay()) {
            return sun_icon_dic[weatherCode] || '';
        } else {
            return moon_icon_dic[weatherCode] || '';
        }
    }

    get weatherTime3() {
        return 'بعد غداً';
    }

    // -------------------------------------------
    getHourlyByIndex(index, dict) {
        var arValue = null;
        try {
            arValue =
                this.state?.weather?.[0]?.hourly?.[index]?.lang_ar[0]?.value;
        } catch (TypeError) {
            arValue =
                this.state?.weather?.[0]?.hourly?.[index]?.weatherDesc?.[0]
                    ?.value || '-';
        }
        const hourly = {
            tempC: this.state?.weather?.[0]?.hourly?.[index]?.tempC || '',
            lang_ar: arValue,
            weatherDesc:
                this.state?.weather?.[0]?.hourly?.[index]?.weatherDesc?.[0]
                    ?.value || '',
            weatherCode:
                dict[this.state?.weather?.[0]?.hourly?.[index]?.weatherCode] ||
                '',
        };

        return hourly;
    }

    get hourly() {
        const weatherData = {
            hour1: {
                time: `09:00 AM`,
                ...this.getHourlyByIndex(3, sun_icon_dic),
            },
            hour2: {
                time: `12:00 PM`,
                ...this.getHourlyByIndex(4, sun_icon_dic),
            },
            hour3: {
                time: `09:00 PM`,
                ...this.getHourlyByIndex(6, moon_icon_dic),
            },
            hour4: {
                time: `12:00 AM`,
                ...this.getHourlyByIndex(7, moon_icon_dic),
            },
        };

        return weatherData;
    }

    // get avgTempC4() {
    //     return `${this.state.weather[0].hourly[7].tempC} C°`;
    // }

    // get weatherCode4() {
    //     const weatherCode = this.state?.weather?.[2]?.hourly?.[4]?.weatherCode;

    //     if (this.isDay()) {
    //         return sun_icon_dic[weatherCode] || '';
    //     } else {
    //         return moon_icon_dic[weatherCode] || '';
    //     }
    // }

    // get weatherTime4() {
    //     return "12 PM";
    // }
}

// the singleton instance
const weatherService = new WeatherService();

// export to use in other modules
export default weatherService;

const moon_icon_dic = {
    395: '',
    392: '',
    389: '',
    386: '',
    377: '',
    374: '',
    371: '',
    368: '',
    365: '',
    362: '',
    359: '',
    356: '',
    353: '',
    350: '',
    338: '',
    335: '',
    332: '',
    329: '',
    326: '',
    323: '',
    320: '',
    317: '',
    314: '',
    311: '',
    308: '',
    305: '',
    302: '',
    299: '',
    296: '',
    293: '',
    284: '',
    281: '',
    266: '',
    263: '',
    260: '',
    248: '',
    230: '',
    227: '',
    200: '',
    185: '',
    182: '',
    179: '',
    176: '',
    143: '',
    122: '',
    119: '',
    116: '',
    113: '',
};

const sun_icon_dic = {
    395: '',
    392: '',
    389: '',
    386: '',
    377: '',
    374: '',
    371: '',
    368: '',
    365: '',
    362: '',
    359: '',
    356: '',
    353: '',
    350: '',
    338: '',
    335: '',
    332: '',
    329: '',
    326: '',
    323: '',
    320: '',
    317: '',
    314: '',
    311: '',
    308: '',
    305: '',
    302: '',
    299: '',
    296: '',
    293: '',
    284: '',
    281: '',
    266: '',
    263: '',
    260: '',
    248: '',
    230: '',
    227: '',
    200: '',
    185: '',
    182: '',
    179: '',
    176: '',
    143: '',
    122: '',
    119: '',
    116: '',
    113: '',
};

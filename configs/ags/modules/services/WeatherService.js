// import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
// import Service from 'resource:///com/github/Aylur/ags/service.js';
import { Service, Utils } from '../utils/imports.js';


class WeatherService extends Service {
    static {
        Service.register(this,
            {},
            {
                // TODAY
                'arValue': ['string', 'r'],
                'weatherCode': ['string', 'r'],
                'maxTempC': ['float', 'r'],
                'minTempC': ['float', 'r'],
                'feelsLike': ['float', 'r'],
                'tempC': ['float', 'r'],

                // HOURS
                'avgTempC1': ['string', 'r'],
                'weatherCode1': ['string', 'r'],
                'weatherTime1': ['string', 'r'],

                'avgTempC2': ['string', 'r'],
                'weatherCode2': ['string', 'r'],
                'weatherTime2': ['string', 'r'],

                'avgTempC3': ['string', 'r'],
                'weatherCode3': ['string', 'r'],
                'weatherTime3': ['string', 'r'],

                // 'avgTempC4': ['string', 'r'],
                // 'weatherCode4': ['string', 'r'],
                // 'weatherTime4': ['string', 'r'],
            }
        );
    }

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
            `ar.wttr.in/sanaa?format=j1`
        ]).then(val => {
            const jsonData = JSON.parse(val);
            this.state = jsonData;
            this.emit("changed");
        }).catch(() => {
            const source = setTimeout(() => {
                this.getWeather()
                source.destroy()
            }, 300000);
        })
    }

    isDay() {
        const sunsetTime = "18:30";

        const currentDate = new Date();

        const currentHour = currentDate.getHours();
        const currentMinute = currentDate.getMinutes();

        const [sunsetHour, sunsetMinute] = sunsetTime.split(":").map(Number);

        const sunsetMinutes = sunsetHour * 60 + sunsetMinute;
        const currentMinutes = currentHour * 60 + currentMinute;

        return currentMinutes < sunsetMinutes;
    }

    get arValue() {
        return this.state?.current_condition?.[0]?.lang_ar?.[0]?.value || '';
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

    get feelsLike() {
        return this.state?.current_condition?.[0].FeelsLikeC || '';
    }

    get feelsLike() {
        return this.state?.current_condition?.[0].temp_C || '';
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
        return "اليوم";
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
        return "غداً";
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
        return "بعد غداً";
    }

    // -------------------------------------------
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
    "395": "",
    "392": "⛈",
    "389": "⛈",
    "386": "⛈",
    "377": "",
    "374": "",
    "371": "",
    "368": "",
    "365": "",
    "362": "",
    "359": "",
    "356": "",
    "353": "",
    "350": "",
    "338": "",
    "335": "",
    "332": "",
    "329": "",
    "326": "",
    "323": "",
    "320": "",
    "317": "",
    "314": "",
    "311": "",
    "308": "",
    "305": "",
    "302": "",
    "299": "",
    "296": "",
    "293": "",
    "284": "",
    "281": "",
    "266": "",
    "263": "",
    "260": "🌫",
    "248": "🌫",
    "230": "",
    "227": "",
    "200": "⛈",
    "185": "",
    "182": "",
    "179": "",
    "176": "",
    "143": "🌫",
    "122": "🌥",
    "119": "",
    "116": "",
    "113": ""
};

const sun_icon_dic = {
    "395": "",
    "392": "⛈",
    "389": "⛈",
    "386": "⛈",
    "377": "",
    "374": "",
    "371": "",
    "368": "",
    "365": "",
    "362": "",
    "359": "",
    "356": "",
    "353": "",
    "350": "",
    "338": "",
    "335": "",
    "332": "",
    "329": "",
    "326": "",
    "323": "",
    "320": "",
    "317": "",
    "314": "",
    "311": "",
    "308": "",
    "305": "",
    "302": "",
    "299": "",
    "296": "",
    "293": "",
    "284": "",
    "281": "",
    "266": "",
    "263": "",
    "260": "🌫",
    "248": "🌫",
    "230": "",
    "227": "",
    "200": "⛈",
    "185": "",
    "182": "",
    "179": "",
    "176": "",
    "143": "🌫",
    "122": "🌥",
    "119": "",
    "116": "",
    "113": ""
};

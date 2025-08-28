pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell

import "root:/config"

Singleton {
    id: root

    // ========================================================================
    // 0. Icon Dictionaries
    // ========================================================================

    property var sun_icon_dic: ({
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
            113: ''
        })

    property var moon_icon_dic: ({
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
            113: ''
        })

    // ========================================================================
    // 1. Prperties
    // ========================================================================
    property bool isLoading: true
    property string lastUpdated: ""
    property string areaName: "..."
    property string countryName: "..."
    property int currentTemp: 0
    property int feelsLike: 0
    property string weatherDescription: "Loading..."
    property string weatherCode: "113"
    property string weatherIcon: "" // Default sun icon
    property int humidity: 0
    property int windSpeed: 0
    property string windDirection: ""
    property int pressure: 0
    property int visibility: 0
    property int uvIndex: 0
    property string sunrise: "00:00"
    property string sunset: "00:00"
    property string moonPhase: "..."
    property var dailyForecast: []
    property var hourlyForecast: []

    // ========================================================================
    // 2. Signals
    // ========================================================================
    signal weatherUpdated
    signal fetchFailed(string error)

    signal chanceOfRainNotified(string message)
    signal chanceOfSnowNotified(string message)
    signal chanceOfFrostNotified(string message)
    signal chanceOfFogNotified(string message)
    signal chanceOfRemdryNotified(string message)
    signal chanceOfThunderNotified(string message)
    signal chanceOfWindyNotified(string message)
    signal chanceOfHotWeatherNotified(string message)

    // ========================================================================
    // 3. Logic
    // ========================================================================
    function getWeatherData() {
        const location = App.weather.location;
        // const local = App.weather.language;

        getWeatherProcess.command = ['curl', `https://wttr.in/${location}?format=j1`];
        getWeatherProcess.running = true;
    }

    Process {
        id: getWeatherProcess
        // command: ['curl', 'https://wttr.in/Sanaa?format=j1']
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text;
                if (output && output.trim() !== "") {
                    parseWeatherData(output);
                } else {
                    isLoading = false;
                    fetchFailed("Received empty data from the server.");
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error fetching weather data:", data)
        }
    }

    // --- Helper functions for icon selection ---

    // Parses a time string like "06:30 AM" into a comparable Date object
    function _parseTime(timeStr) {
        if (!timeStr || timeStr === "N/A")
            return null;
        const parts = timeStr.match(/(\d+):(\d+)\s*(AM|PM)/i);
        if (!parts)
            return null;

        let hours = parseInt(parts[1], 10);
        const minutes = parseInt(parts[2], 10);
        const ampm = parts[3].toUpperCase();

        if (ampm === "PM" && hours < 12) {
            hours += 12;
        }
        if (ampm === "AM" && hours === 12) {
            // Midnight case
            hours = 0;
        }

        const date = new Date();
        date.setHours(hours, minutes, 0, 0);
        return date;
    }

    // Determines if the current time is daytime
    function _isDayTime(sunriseStr, sunsetStr) {
        const now = new Date();
        const sunriseTime = _parseTime(sunriseStr);
        const sunsetTime = _parseTime(sunsetStr);

        // If parsing fails, default to daytime
        if (!sunriseTime || !sunsetTime) {
            console.warn("Could not parse sunrise/sunset times. Defaulting to daytime.");
            return true;
        }

        return now >= sunriseTime && now < sunsetTime;
    }

    // Gets the appropriate weather icon
    function getWeatherIcon(code, isDay) {
        if (isDay) {
            // Returns default sun icon if code not found
            return sun_icon_dic[code] || '';
        } else {
            // Returns default moon icon if code not found
            return moon_icon_dic[code] || '';
        }
    }

    function parseWeatherData(jsonData) {
        console.info("Starting to parse weather data...");
        try {
            const data = JSON.parse(jsonData);

            // Section 1: Current Condition
            const current = data?.current_condition?.[0];
            currentTemp = parseInt(current?.temp_C) || 0;
            feelsLike = parseInt(current?.FeelsLikeC) || 0;
            weatherDescription = current?.weatherDesc?.[0]?.value || "Not available";
            weatherCode = current?.weatherCode || "113";
            humidity = parseInt(current?.humidity) || 0;
            windSpeed = parseInt(current?.windspeedKmph) || 0;
            windDirection = current?.winddir16Point || "";
            pressure = parseInt(current?.pressure) || 0;
            visibility = parseInt(current?.visibility) || 0;
            uvIndex = parseInt(current?.uvIndex) || 0;

            // Section 2: Location Info
            const area = data?.nearest_area?.[0];
            areaName = area?.areaName?.[0]?.value || "Unknown location";
            countryName = area?.country?.[0]?.value || "";

            // Section 3: Astronomical Data
            const astronomy = data?.weather?.[0]?.astronomy?.[0];
            sunrise = astronomy?.sunrise || "N/A";
            sunset = astronomy?.sunset || "N/A";
            moonPhase = astronomy?.moon_phase || "N/A";

            // --- Determine correct icon based on day/night ---
            const isDay = _isDayTime(sunrise, sunset);
            weatherIcon = getWeatherIcon(weatherCode, isDay);

            // Section 4: Daily Forecast
            let dailyData = [];
            if (data?.weather && Array.isArray(data.weather)) {
                for (let day of data.weather) {
                    const representativeHour = day?.hourly?.[4] || day?.hourly?.[0];
                    dailyData.push({
                        date: day?.date || "",
                        dayName: getDayName(day?.date),
                        minTemp: parseInt(day?.mintempC) || 0,
                        maxTemp: parseInt(day?.maxtempC) || 0,
                        avgTemp: parseInt(day?.avgtempC) || 0,
                        weatherCode: representativeHour?.weatherCode || "113",
                        description: representativeHour?.weatherDesc?.[0]?.value || "...",
                        icon: getWeatherIcon(representativeHour?.weatherCode || "113", true) // Assume day for forecast icons
                    });
                }
            }
            dailyForecast = dailyData;

            // Section 5: Hourly Forecast
            let hourlyData = [];
            const todayHourly = data?.weather?.[0]?.hourly;
            if (todayHourly && Array.isArray(todayHourly)) {
                for (let hour of todayHourly) {
                    const timeStr = (parseInt(hour.time) / 100).toString().padStart(2, '0') + ":00";
                    hourlyData.push({
                        time: timeStr,
                        temp: parseInt(hour?.tempC) || 0,
                        weatherCode: hour?.weatherCode || "113",
                        description: hour?.weatherDesc?.[0]?.value || "...",
                        chanceOfRain: parseInt(hour?.chanceofrain) || 0,
                        chanceOfSnow: parseInt(hour?.chanceofsnow) || 0,
                        chanceOfFrost: parseInt(hour?.chanceoffrost) || 0,
                        chanceOfFog: parseInt(hour?.chanceoffog) || 0,
                        chanceOfRemdry: parseInt(hour?.chanceofremdry) || 0,
                        chanceOfThunder: parseInt(hour?.chanceofthunder) || 0,
                        chanceOfWindy: parseInt(hour?.chanceofwindy) || 0,
                        chanceOfHotTemp: parseInt(hour?.chanceofhightemp) || 0,
                        icon: getWeatherIcon(hour?.weatherCode || "113", _isDayTime(sunrise, sunset))
                    });
                }
            }
            hourlyForecast = hourlyData;

            lastUpdated = new Date().toLocaleTimeString([], {
                hour: '2-digit',
                minute: '2-digit'
            });
            console.log("✅ Weather data parsed successfully for:", areaName);
            checkWeatherConditions();
            isLoading = false;
            weatherUpdated();
        } catch (e) {
            isLoading = false;
            console.error("Fatal error parsing JSON data:", e.message, e.stack);
            fetchFailed("Invalid data received from the server.");
        }
    }

    function getDayName(dateString) {
        if (!dateString)
            return "";
        const date = new Date(dateString);
        const today = new Date();
        const tomorrow = new Date();
        tomorrow.setDate(today.getDate() + 1);
        if (date.toDateString() === today.toDateString())
            return "Today";
        if (date.toDateString() === tomorrow.toDateString())
            return "Tomorrow";
        return date.toLocaleDateString('en-US', {
            weekday: 'long'
        });
    }

    function checkWeatherConditions() {
        if (hourlyForecast.length === 0)
            return;

        let maxRain = 0, maxSnow = 0, maxFrost = 0, maxFog = 0;
        let maxThunder = 0, maxWindy = 0, maxHotTemp = 0;

        // البدء بقيم أولية عالية للمتغيرات الصغرى
        let minRain = 101, minSnow = 101, minFrost = 101, minFog = 101;
        let minThunder = 101, minWindy = 101, minHotTemp = 101;

        for (const hour of hourlyForecast) {
            // حساب القيم القصوى
            if (hour.chanceOfRain > maxRain)
                maxRain = hour.chanceOfRain;
            if (hour.chanceOfSnow > maxSnow)
                maxSnow = hour.chanceOfSnow;
            if (hour.chanceOfFrost > maxFrost)
                maxFrost = hour.chanceOfFrost;
            if (hour.chanceOfFog > maxFog)
                maxFog = hour.chanceOfFog;
            if (hour.chanceOfThunder > maxThunder)
                maxThunder = hour.chanceOfThunder;
            if (hour.chanceOfWindy > maxWindy)
                maxWindy = hour.chanceOfWindy;
            if (hour.chanceOfHotTemp > maxHotTemp)
                maxHotTemp = hour.chanceOfHotTemp;

            // حساب القيم الصغرى
            if (hour.chanceOfRain < minRain)
                minRain = hour.chanceOfRain;
            if (hour.chanceOfSnow < minSnow)
                minSnow = hour.chanceOfSnow;
            if (hour.chanceOfFrost < minFrost)
                minFrost = hour.chanceOfFrost;
            if (hour.chanceOfFog < minFog)
                minFog = hour.chanceOfFog;
            if (hour.chanceOfThunder < minThunder)
                minThunder = hour.chanceOfThunder;
            if (hour.chanceOfWindy < minWindy)
                minWindy = hour.chanceOfWindy;
            if (hour.chanceOfHotTemp < minHotTemp)
                minHotTemp = hour.chanceOfHotTemp;
        }

        // --== إرسال الإشعارات مع النطاق الكامل (الأدنى والأقصى) ==--

        if (maxRain > 10) {
            chanceOfRainNotified(`Min chance of rain today is ${minRain} max is ${maxRain}%`);
        }
        if (maxSnow > 20) {
            chanceOfSnowNotified(`Min chance of snow today is ${minSnow}% max is ${maxSnow}%`);
        }
        if (maxFrost > 10) {
            chanceOfFrostNotified(`Warning: Chance of frost today is between ${minFrost}% and ${maxFrost}%`);
        }
        if (maxFog > 10) {
            chanceOfFogNotified(`Warning: High chance of fog, ranging from ${minFog}% to ${maxFog}%`);
        }
        if (maxThunder > 10) {
            chanceOfThunderNotified(`Warning: Thunderstorm chance today is between ${minThunder}% and ${maxThunder}%`);
        }
        if (maxWindy > 10) {
            chanceOfWindyNotified(`It might get windy today, with chances from ${minWindy}% to ${maxWindy}%`);
        }
        if (maxHotTemp > 10) {
            chanceOfHotWeatherNotified(`Warning: High temperature expected. Chance is between ${minHotTemp}% and ${maxHotTemp}%`);
        }
    }

    // ========================================================================
    // 4. Automation
    // ========================================================================
    Timer {
        interval: 900000 // 15 minutes
        running: true
        repeat: true
        onTriggered: {
            console.info("Timer triggered: Refreshing weather data...");
            getWeatherData();
        }
    }

    Component.onCompleted: {
        console.info("WeatherService started. Initial fetch...");
        getWeatherData();
    }
}

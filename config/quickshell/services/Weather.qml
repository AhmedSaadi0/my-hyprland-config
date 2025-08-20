pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    // ========================================================================
    // 0. قواميس الأيقونات (Icon Dictionaries)
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
    // 1. الخصائص (Properties)
    // ========================================================================
    property bool isLoading: true
    property string lastUpdated: ""
    property string areaName: "..."
    property string countryName: "..."
    property int currentTemp: 0
    property int feelsLike: 0
    property string weatherDescription: "جاري التحميل..."
    property string weatherCode: "113"
    property string weatherIcon: "" // أيقونة شمس افتراضية
    property string highTemp: "35°"
    property string lowTemp: "28°"
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
    // 2. الإشارات (Signals)
    // ========================================================================
    signal weatherUpdated
    signal coldWeatherWarning(string message)
    signal hotWeatherWarning(string message)
    signal rainChanceWarning(string message)
    signal fetchFailed(string error)

    // ========================================================================
    // 3. المنطق (Logic)
    // ========================================================================
    Process {
        id: getWeatherProcess
        command: ['curl', 'https://ar.wttr.in/Sanaa?format=j1']
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text;
                if (output && output.trim() !== "") {
                    parseWeatherData(output);
                } else {
                    isLoading = false;
                    fetchFailed("تم استلام بيانات فارغة من الخادم.");
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error getting weather data:", data)
        }
    }

    // --- دوال مساعدة جديدة لاختيار الأيقونة ---

    // دالة لتحويل وقت بصيغة "06:30 AM" إلى كائن Date صالح للمقارنة
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
            // منتصف الليل
            hours = 0;
        }

        const date = new Date();
        date.setHours(hours, minutes, 0, 0);
        return date;
    }

    // دالة لتحديد ما إذا كان الوقت نهاراً
    function _isDayTime(sunriseStr, sunsetStr) {
        const now = new Date();
        const sunriseTime = _parseTime(sunriseStr);
        const sunsetTime = _parseTime(sunsetStr);

        // في حال فشل التحويل، نفترض أنه نهار كقيمة افتراضية
        if (!sunriseTime || !sunsetTime) {
            console.warn("Could not parse sunrise/sunset times. Defaulting to daytime.");
            return true;
        }

        return now >= sunriseTime && now < sunsetTime;
    }

    // دالة لجلب الأيقونة المناسبة
    function getWeatherIcon(code, isDay) {
        if (isDay) {
            // إذا لم يجد الكود، يرجع أيقونة الشمس الافتراضية
            return sun_icon_dic[code] || '';
        } else {
            // إذا لم يجد الكود، يرجع أيقونة القمر الافتراضية
            return moon_icon_dic[code] || '';
        }
    }

    function parseWeatherData(jsonData) {
        console.info("Starting to parse weather data...");
        try {
            const data = JSON.parse(jsonData);

            // القسم الأول: الطقس الحالي
            const current = data?.current_condition?.[0];
            currentTemp = parseInt(current?.temp_C) || 0;
            feelsLike = parseInt(current?.FeelsLikeC) || 0;
            weatherDescription = current?.lang_ar?.[0]?.value || current?.weatherDesc?.[0]?.value || "غير متوفر";
            weatherCode = current?.weatherCode || "113";
            humidity = parseInt(current?.humidity) || 0;
            windSpeed = parseInt(current?.windspeedKmph) || 0;
            windDirection = current?.winddir16Point || "";
            pressure = parseInt(current?.pressure) || 0;
            visibility = parseInt(current?.visibility) || 0;
            uvIndex = parseInt(current?.uvIndex) || 0;

            // القسم الثاني: معلومات الموقع
            const area = data?.nearest_area?.[0];
            areaName = area?.areaName?.[0]?.value || "مكان غير معروف";
            countryName = area?.country?.[0]?.value || "";

            // القسم الثالث: البيانات الفلكية
            const astronomy = data?.weather?.[0]?.astronomy?.[0];
            sunrise = astronomy?.sunrise || "N/A";
            sunset = astronomy?.sunset || "N/A";
            moonPhase = astronomy?.moon_phase || "N/A";

            // =============================================
            // == الجزء الجديد: تحديد الأيقونة الصحيحة  ====
            // =============================================
            const isDay = _isDayTime(sunrise, sunset);
            weatherIcon = getWeatherIcon(weatherCode, isDay);
            // =============================================

            // القسم الرابع: توقعات الأيام القادمة
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
                        description: representativeHour?.lang_ar?.[0]?.value || representativeHour?.weatherDesc?.[0]?.value || "...",
                        // يمكنك إضافة أيقونة لكل يوم أيضاً بنفس الطريقة
                        icon: getWeatherIcon(representativeHour?.weatherCode || "113", true) // نفترض النهار للتوقعات
                    });
                }
            }
            dailyForecast = dailyData;

            // القسم الخامس: توقعات الساعات القادمة
            let hourlyData = [];
            const todayHourly = data?.weather?.[0]?.hourly;
            if (todayHourly && Array.isArray(todayHourly)) {
                for (let hour of todayHourly) {
                    const timeStr = (parseInt(hour.time) / 100).toString().padStart(2, '0') + ":00";
                    hourlyData.push({
                        time: timeStr,
                        temp: parseInt(hour?.tempC) || 0,
                        weatherCode: hour?.weatherCode || "113",
                        description: hour?.lang_ar?.[0]?.value || hour?.weatherDesc?.[0]?.value || "...",
                        chanceOfRain: parseInt(hour?.chanceofrain) || 0,
                        // يمكنك إضافة أيقونة لكل ساعة أيضاً
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
            console.error("فشل كارثي في معالجة بيانات JSON:", e.message, e.stack);
            fetchFailed("بيانات غير صالحة من الخادم.");
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
            return "اليوم";
        if (date.toDateString() === tomorrow.toDateString())
            return "غداً";
        return date.toLocaleDateString('ar-EG', {
            weekday: 'long'
        });
    }

    function checkWeatherConditions() {
        if (dailyForecast.length === 0)
            return;
        const today = dailyForecast[0];
        if (today.minTemp <= 7) {
            coldWeatherWarning(`طقس بارد متوقع! الصغرى: ${today.minTemp}°`);
        }
        if (today.maxTemp > 35) {
            hotWeatherWarning(`طقس حار متوقع! العظمى: ${today.maxTemp}°`);
        }
        let maxRainChance = 0;
        for (let i = 0; i < hourlyForecast.length; i++) {
            if (hourlyForecast[i].chanceOfRain > maxRainChance) {
                maxRainChance = hourlyForecast[i].chanceOfRain;
            }
        }
        if (maxRainChance > 60) {
            rainChanceWarning(`فرصة هطول أمطار اليوم تصل إلى ${maxRainChance}%`);
        }
    }

    // ========================================================================
    // 4. التشغيل التلقائي (Automation)
    // ========================================================================
    Timer {
        interval: 900000
        running: true
        repeat: true
        onTriggered: {
            console.info("تحديث الطقس تلقائياً...");
            getWeatherProcess.running = true;
        }
    }
    Component.onCompleted: {
        console.info("بدء خدمة الطقس...");
        getWeatherProcess.running = true;
    }
}

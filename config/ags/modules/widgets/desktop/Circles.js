import FuzzyClock from '../FuzzyClock.js';
import Saying from '../Saying.js';
import { Mpris, Utils, Widget } from '../../utils/imports.js';
import { selectedMusicPlayer } from '../MusicPLayer.js';
import NestedCircles from '../../components/NestedCircles.js';
import { TitleText } from '../../utils/helpers.js';
import settings from '../../settings.js';

let cpuNestedCircles1 = NestedCircles({
    child: Widget.Label({
        className: 'desktop-cpu-circle-icon',
        label: '',
    }),
    innerCircle1Css: 'desktop-core-circle',
    innerCircle2Css: 'desktop-core-circle',
    innerCircle3Css: 'desktop-core-circle',
    innerCircle4Css: 'desktop-core-circle',
    innerCircle5Css: 'desktop-core-circle',
    innerCircle6Css: 'desktop-core-circle',
    outerCircle1Css: 'desktop-core-circle',
    outerCircle2Css: 'desktop-core-circle',
    outerCircle3Css: 'desktop-core-circle',
    outerCircle4Css: 'desktop-core-circle',
});

let cpuNestedCircles2 = NestedCircles({
    child: Widget.Label({
        className: 'desktop-cpu-circle-icon',
        label: '',
    }),
    innerCircle1Css: 'desktop-core-circle',
    innerCircle2Css: 'desktop-core-circle',
    innerCircle3Css: 'desktop-core-circle',
    innerCircle4Css: 'desktop-core-circle',
    innerCircle5Css: 'desktop-core-circle',
    innerCircle6Css: 'desktop-core-circle',
    outerCircle1Css: 'desktop-core-circle',
    outerCircle2Css: 'desktop-core-circle',
    outerCircle3Css: 'desktop-core-circle',
    outerCircle4Css: 'desktop-core-circle',
});
const subTitleArgs = {
    titleClass: 'information-widget-subtitle',
    textClass: 'information-widget-subtext',
    titleXalign: 0,
    textXalign: 1,
    vertical: false,
    titleTruncate: 'end',
    textTruncate: 'end',
};

const titleArgs = {
    vertical: false,
    spacing: 10,
    boxClass: 'information-widget-title',
};

const informationBox = Widget.Box({
    vertical: true,
    children: [
        TitleText({
            title: 'لينكس',
            text: '',
            vertical: false,
            spacing: 60,
            boxClass: 'information-widget-header',
        }),
        TitleText({
            title: 'النظام',
            text: '',
            ...titleArgs,
        }),
        TitleText({
            title: 'الاسم',
            text: '',
            ...subTitleArgs,
        }),
        TitleText({
            title: 'الهوست',
            text: '',
            ...subTitleArgs,
        }),
        TitleText({
            title: 'وقت التشغيل',
            text: '',
            ...subTitleArgs,
        }),
        TitleText({
            title: 'مدير الحزم',
            text: '',
            ...subTitleArgs,
        }),
        TitleText({
            title: 'الحزم',
            text: '',
            ...subTitleArgs,
        }),
    ],
}).poll(1000 * 60 * 6, (self) => {
    Utils.execAsync(settings.scripts.systemInfo)
        .then((val) => {
            const data = JSON.parse(val);
            self.children[2].children[1].label = data.kernel_version;
            self.children[3].children[1].label = data.host_name;
            self.children[4].children[1].label = data.uptime;
            self.children[5].children[1].label = data.package_manager;
            self.children[6].children[1].label =
                data.installed_packages.toString();
        })
        .catch(print);
});

const MusicWidget = Widget.Box({
    spacing: 18,
    homogeneous: false,
    vertical: true,
    children: [
        Widget.Box({
            vertical: true,
            className: 'desktop-wd-music-player-box',
            homogeneous: true,
            children: [
                Widget.Label({
                    className: 'desktop-wd-music-player-title',
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
                Widget.Label({
                    className: 'desktop-wd-music-player-artist',
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
            ],
        }).hook(Mpris, (box) => {
            if (
                Mpris?.players.length > 0 &&
                Mpris?.getPlayer(selectedMusicPlayer)
            ) {
                box.children[0].label =
                    Mpris?.getPlayer(selectedMusicPlayer)?.trackTitle;
                box.children[1].label =
                    Mpris?.getPlayer(selectedMusicPlayer)?.trackArtists[0];
            } else {
                box.children[0].label = 'لا توجد موسيقى قيد التشغبل';
                box.children[1].label = 'لا توجد موسيقى قيد التشغبل';
            }
        }),
    ],
}).poll(3 * 1000, (self) => {
    Utils.execAsync(`/home/${Utils.USER}/.config/ags/scripts/cpu_cores.sh`)
        .then((val) => {
            const data = JSON.parse(val);
            cpuNestedCircles1.innerCircle1.value = data[1] / 100;
            cpuNestedCircles1.innerCircle2.value = data[2] / 100;
            cpuNestedCircles1.innerCircle3.value = data[3] / 100;
            cpuNestedCircles1.innerCircle4.value = data[4] / 100;
            cpuNestedCircles1.innerCircle5.value = data[5] / 100;
            cpuNestedCircles1.innerCircle6.value = data[6] / 100;
            // Circle 2
            cpuNestedCircles2.innerCircle1.value = data[7] / 100;
            cpuNestedCircles2.innerCircle2.value = data[8] / 100;
            cpuNestedCircles2.innerCircle3.value = data[9] / 100;
            cpuNestedCircles2.innerCircle4.value = data[10] / 100;
            cpuNestedCircles2.innerCircle5.value = data[11] / 100;
            cpuNestedCircles2.innerCircle6.value = data[12] / 100;
        })
        .catch(print);

    Utils.execAsync(`/home/${Utils.USER}/.config/ags/scripts/devices_temps.sh`)
        .then((val) => {
            const data = JSON.parse(val);
            cpuNestedCircles1.outerCircle1.value = data.cpu_core0 / 100;
            cpuNestedCircles1.outerCircle2.value = data.cpu_core1 / 100;
            cpuNestedCircles1.outerCircle3.value = data.cpu_core2 / 100;
            cpuNestedCircles1.outerCircle4.value = data.cpu_core3 / 100;
            // Circle 2
            cpuNestedCircles2.outerCircle1.value = data.cpu_core4 / 100;
            cpuNestedCircles2.outerCircle2.value = data.cpu_core5 / 100;
            cpuNestedCircles2.outerCircle3.value = data.nvme_total / 100;
            cpuNestedCircles2.outerCircle4.value = data.wifi / 100;
        })
        .catch(print);
});

const CircleMusicWidget = () =>
    Widget.Window({
        name: `desktop_circles_widget`,
        margins: [135, 60],
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['bottom', 'right'],
        child: MusicWidget,
    });

const SayingWidget = () =>
    Widget.Window({
        name: `desktop_circles_saying_widget`,
        margins: [920, 30],
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['top', 'right'],
        child: Saying(),
    });

const FuzzyClockWidget = () =>
    Widget.Window({
        name: `desktop_circles_saying_widget`,
        margins: [230, 60],
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['bottom', 'right'],
        child: FuzzyClock(),
    });

const InformationWidget = () =>
    Widget.Window({
        name: `desktop_circles_information_widget`,
        margins: [40, 40],
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['top', 'right'],
        child: informationBox,
    });

function createCoreWindow(name, margins, child) {
    return Widget.Window({
        name: name,
        margins: margins,
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['top', 'right'],
        child: child,
    });
}

const circlesMusicWidget = CircleMusicWidget();
const circlesSayingWidget = SayingWidget();
const fuzzyClockWidget = FuzzyClockWidget();
const informationWidget = InformationWidget();

const core1Widget = createCoreWindow(
    'desktop_core_1_widget',
    [95, 407],
    cpuNestedCircles1.innerCircle1
);
const core2Widget = createCoreWindow(
    'desktop_core_2_widget',
    [79, 391],
    cpuNestedCircles1.innerCircle2
);
const core3Widget = createCoreWindow(
    'desktop_core_3_widget',
    [62, 374],
    cpuNestedCircles1.innerCircle3
);

const core4Widget = createCoreWindow(
    'desktop_core_4_widget',
    [95, 407],
    cpuNestedCircles1.innerCircle4
);
const core5Widget = createCoreWindow(
    'desktop_core_5_widget',
    [79, 391],
    cpuNestedCircles1.innerCircle5
);
const core6Widget = createCoreWindow(
    'desktop_core_6_widget',
    [62, 374],
    cpuNestedCircles1.innerCircle6
);

const temp1Widget = createCoreWindow(
    'desktop_temp1_widget',
    [54, 365],
    cpuNestedCircles1.outerCircle1
);

const temp2Widget = createCoreWindow(
    'desktop_temp2_widget',
    [47, 358],
    cpuNestedCircles1.outerCircle2
);

const temp3Widget = createCoreWindow(
    'desktop_temp3_widget',
    [38, 348],
    cpuNestedCircles1.outerCircle3
);

const temp4Widget = createCoreWindow(
    'desktop_temp4_widget',
    [31, 341],
    cpuNestedCircles1.outerCircle4
);

const core7Widget = createCoreWindow(
    'desktop_core_7_widget',
    [326, 407],
    cpuNestedCircles2.innerCircle1
);
const core8Widget = createCoreWindow(
    'desktop_core_8_widget',
    [310, 391],
    cpuNestedCircles2.innerCircle2
);
const core9Widget = createCoreWindow(
    'desktop_core_9_widget',
    [293, 374],
    cpuNestedCircles2.innerCircle3
);

const core10Widget = createCoreWindow(
    'desktop_core_10_widget',
    [326, 407],
    cpuNestedCircles2.innerCircle4
);
const core11Widget = createCoreWindow(
    'desktop_core_11_widget',
    [310, 391],
    cpuNestedCircles2.innerCircle5
);
const core12Widget = createCoreWindow(
    'desktop_core_12_widget',
    [293, 374],
    cpuNestedCircles2.innerCircle6
);

const temp5Widget = createCoreWindow(
    'desktop_temp5_widget',
    [285, 365],
    cpuNestedCircles2.outerCircle1
);

const temp6Widget = createCoreWindow(
    'desktop_temp6_widget',
    [278, 358],
    cpuNestedCircles2.outerCircle2
);

const temp7Widget = createCoreWindow(
    'desktop_temp7_widget',
    [269, 348],
    cpuNestedCircles2.outerCircle3
);

const temp8Widget = createCoreWindow(
    'desktop_temp8_widget',
    [262, 341],
    cpuNestedCircles2.outerCircle4
);

globalThis.ShowCirclesWidget = () => {
    circlesMusicWidget.visible = true;
    circlesSayingWidget.visible = true;
    fuzzyClockWidget.visible = true;
    informationWidget.visible = true;
    core1Widget.visible = true;
    core2Widget.visible = true;
    core3Widget.visible = true;
    core4Widget.visible = true;
    core5Widget.visible = true;
    core6Widget.visible = true;
    core7Widget.visible = true;
    core8Widget.visible = true;
    core9Widget.visible = true;
    core10Widget.visible = true;
    core11Widget.visible = true;
    core12Widget.visible = true;
    temp1Widget.visible = true;
    temp2Widget.visible = true;
    temp3Widget.visible = true;
    temp4Widget.visible = true;
    temp5Widget.visible = true;
    temp6Widget.visible = true;
    temp7Widget.visible = true;
    temp8Widget.visible = true;
};

globalThis.HideCirclesWidget = () => {
    circlesMusicWidget.visible = false;
    circlesSayingWidget.visible = false;
    fuzzyClockWidget.visible = false;
    informationWidget.visible = false;
    core1Widget.visible = false;
    core2Widget.visible = false;
    core3Widget.visible = false;
    core4Widget.visible = false;
    core5Widget.visible = false;
    core6Widget.visible = false;
    core7Widget.visible = false;
    core8Widget.visible = false;
    core9Widget.visible = false;
    core10Widget.visible = false;
    core11Widget.visible = false;
    core12Widget.visible = false;
    temp1Widget.visible = false;
    temp2Widget.visible = false;
    temp3Widget.visible = false;
    temp4Widget.visible = false;
    temp5Widget.visible = false;
    temp6Widget.visible = false;
    temp7Widget.visible = false;
    temp8Widget.visible = false;
};

export default circlesMusicWidget;

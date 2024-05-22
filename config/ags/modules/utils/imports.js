const resource = (file) => `resource:///com/github/Aylur/ags/${file}.js`;
const require = async (file) => (await import(resource(file))).default;
const service = async (file) => await require(`service/${file}`);

export const App = await require('app');
export const Widget = await require('widget');
export const Service = await require('service');
export const Variable = await require('variable');
export const Utils = await import(resource('utils'));

export const Applications = await Service.import('applications');
export const Audio = await Service.import('audio');
export const Battery = await Service.import('battery');
export const Bluetooth = await Service.import('bluetooth');
export const Hyprland = await Service.import('hyprland');
export const Mpris = await Service.import('mpris');
export const Network = await Service.import('network');
export const Notifications = await Service.import('notifications');
export const SystemTray = await Service.import('systemtray');

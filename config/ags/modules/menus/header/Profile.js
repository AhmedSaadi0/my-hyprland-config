import settings from '../../settings.js';

const Profile = () => {
    const userImage = Widget.Icon({
        className: 'profile-icon',
        icon: `${settings.profilePicture}`,
        size: 80,
    });

    const myName = Widget.Label({
        className: 'profile-label',
        label: settings.username,
    });

    return Widget.Box({
        className: 'profile-box',
        vertical: true,
        children: [userImage, myName],
    });
};

export default Profile;

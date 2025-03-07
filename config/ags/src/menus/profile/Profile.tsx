import { Box, Icon, Label } from 'astal/gtk3/widget';
import settings from '../../utils/settings';

const Profile = (): any => {
    const userImage = new Icon({
        className: 'profile-icon',
        icon: settings.profilePicture,
    });

    const myName = new Label({
        className: 'profile-title',
        label: settings.username,
    });

    const major = new Label({
        className: 'profile-sub-title',
        label: 'Software Engineer',
    });

    return new Box({
        className: 'main-menu-header-profile',
        vertical: true,
        children: [userImage, myName, major],
    });
};

export default Profile;

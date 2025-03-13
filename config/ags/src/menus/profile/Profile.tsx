import settings from '../../utils/settings';

const Profile = (): any => (
    <box className="main-menu-header-profile" vertical>
        <icon className="profile-icon" icon={settings.profilePicture} />
        <label className="profile-title" label={settings.username} />
        <label className="profile-sub-title" label="Software Engineer" />
    </box>
);

export default Profile;

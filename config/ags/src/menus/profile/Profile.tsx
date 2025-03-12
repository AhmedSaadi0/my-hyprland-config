import { Box, Icon, Label } from 'astal/gtk3/widget';
import settings from '../../utils/settings';

const Profile = (): any => (
    <Box className="main-menu-header-profile" vertical>
        <Icon className="profile-icon" icon={settings.profilePicture} />
        <Label className="profile-title" label={settings.username} />
        <Label className="profile-sub-title" label="Software Engineer" />
    </Box>
);

export default Profile;

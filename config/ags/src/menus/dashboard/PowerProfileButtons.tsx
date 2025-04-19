import PowerProfiles from 'gi://AstalPowerProfiles';
import strings from '../../utils/strings';
import { bind, Binding } from 'astal';
import DashboardBox from '../../widgets/DashboardBox';

const powerProfiles = PowerProfiles.get_default();

const activeProfile = bind(powerProfiles, 'active-profile');

function ProfileButton({
    profile,
    activeProfile,
    label,
}: {
    profile: string;
    activeProfile: Binding<string>;
    label: string;
}) {
    return (
        <button
            onClick={() => powerProfiles.set_active_profile(profile)}
            className={activeProfile.as((val) =>
                val === profile
                    ? 'theme-btn power-profiles-box-btn power-profiles-box-btn-active'
                    : 'theme-btn'
            )}
        >
            {label}
        </button>
    );
}

const HighPerformance = () => (
    <ProfileButton
        profile="performance"
        activeProfile={activeProfile}
        label={strings.highPerformance}
    />
);

const NormalPerformance = () => (
    <ProfileButton
        profile="balanced"
        activeProfile={activeProfile}
        label={strings.balanced}
    />
);

const LowPerformance = () => (
    <ProfileButton
        profile="power-saver"
        activeProfile={activeProfile}
        label={strings.powerSaver}
    />
);

function buttonsRow() {
    return (
        <box homogeneous={true} spacing={15}>
            <HighPerformance />
            <NormalPerformance />
            <LowPerformance />
        </box>
    );
}

export default (
    <DashboardBox icon="󰎓" text={strings.powerProfile} widget={buttonsRow()} />
);

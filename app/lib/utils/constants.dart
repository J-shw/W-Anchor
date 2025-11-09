/// The possible themes for the application.
enum AppTheme { system, light, dark }

/// The possible alarm statuses.
enum AlarmStatus { none, outsideRadius, noGps }

// The keys for SharedPreferences.

/// The radius (in meters) for the alarm.
const String kAlarmRadius = 'alarm_radius';
/// The theme to use for the application.
const String kTheme = 'theme';

// Default settings

/// The default radius (in meters) for the alarm.
const double defaultAlarmRadius = 30.0;
/// The default theme for the application.
const AppTheme defaultTheme = AppTheme.system;
/// The default alarm message.
const String defaultAlarmMessage = 'All clear';

// Notification constants

const String serviceChannelId = 'w_anchor_service_status';
const String alarmChannelId = 'w_anchor_service_alarm';
const int serviceNotificationId = 1;
const int alarmNotificationId = 2;
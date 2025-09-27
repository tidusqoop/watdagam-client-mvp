import '../../../../shared/domain/value_objects/value_object.dart';

/// Represents notification settings for the user
class NotificationSettings extends ValueObject {
  final bool enablePushNotifications;
  final bool enableGraffitiUpdates;
  final bool enableWallUpdates;
  final bool enableLocationReminders;

  const NotificationSettings({
    required this.enablePushNotifications,
    required this.enableGraffitiUpdates,
    required this.enableWallUpdates,
    required this.enableLocationReminders,
  });

  /// Creates default notification settings
  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      enablePushNotifications: true,
      enableGraffitiUpdates: true,
      enableWallUpdates: true,
      enableLocationReminders: false,
    );
  }

  /// Creates disabled notification settings
  factory NotificationSettings.disabled() {
    return const NotificationSettings(
      enablePushNotifications: false,
      enableGraffitiUpdates: false,
      enableWallUpdates: false,
      enableLocationReminders: false,
    );
  }

  /// Creates a copy with optionally updated values
  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableGraffitiUpdates,
    bool? enableWallUpdates,
    bool? enableLocationReminders,
  }) {
    return NotificationSettings(
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableGraffitiUpdates: enableGraffitiUpdates ?? this.enableGraffitiUpdates,
      enableWallUpdates: enableWallUpdates ?? this.enableWallUpdates,
      enableLocationReminders: enableLocationReminders ?? this.enableLocationReminders,
    );
  }

  /// Creates a NotificationSettings from JSON map
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePushNotifications: json['enablePushNotifications'] as bool,
      enableGraffitiUpdates: json['enableGraffitiUpdates'] as bool,
      enableWallUpdates: json['enableWallUpdates'] as bool,
      enableLocationReminders: json['enableLocationReminders'] as bool,
    );
  }

  /// Converts NotificationSettings to JSON map
  Map<String, dynamic> toJson() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableGraffitiUpdates': enableGraffitiUpdates,
      'enableWallUpdates': enableWallUpdates,
      'enableLocationReminders': enableLocationReminders,
    };
  }

  @override
  List<Object?> get props => [
    enablePushNotifications,
    enableGraffitiUpdates,
    enableWallUpdates,
    enableLocationReminders,
  ];
}

/// Represents user preferences including location tracking, notifications, and language
class UserPreferences extends ValueObject {
  final bool enableLocationTracking;
  final NotificationSettings notifications;
  final String preferredLanguage;

  const UserPreferences({
    required this.enableLocationTracking,
    required this.notifications,
    required this.preferredLanguage,
  });

  /// Creates default user preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      enableLocationTracking: true,
      notifications: NotificationSettings.defaults(),
      preferredLanguage: 'ko',
    );
  }

  /// Creates privacy-focused preferences with minimal tracking
  factory UserPreferences.privacyFocused() {
    return UserPreferences(
      enableLocationTracking: false,
      notifications: NotificationSettings.disabled(),
      preferredLanguage: 'ko',
    );
  }

  /// Returns true if all privacy-sensitive features are disabled
  bool get isPrivacyMode {
    return !enableLocationTracking &&
           !notifications.enablePushNotifications &&
           !notifications.enableLocationReminders;
  }

  /// Returns true if location features are available
  bool get canUseLocationFeatures => enableLocationTracking;

  /// Returns true if notifications are enabled
  bool get hasNotificationsEnabled {
    return notifications.enablePushNotifications &&
           (notifications.enableGraffitiUpdates ||
            notifications.enableWallUpdates ||
            notifications.enableLocationReminders);
  }

  /// Creates a copy with optionally updated values
  UserPreferences copyWith({
    bool? enableLocationTracking,
    NotificationSettings? notifications,
    String? preferredLanguage,
  }) {
    return UserPreferences(
      enableLocationTracking: enableLocationTracking ?? this.enableLocationTracking,
      notifications: notifications ?? this.notifications,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  /// Updates notification settings
  UserPreferences updateNotifications(NotificationSettings newNotifications) {
    return copyWith(notifications: newNotifications);
  }

  /// Toggles location tracking
  UserPreferences toggleLocationTracking() {
    return copyWith(enableLocationTracking: !enableLocationTracking);
  }

  /// Changes the preferred language
  UserPreferences changeLanguage(String newLanguage) {
    return copyWith(preferredLanguage: newLanguage);
  }

  /// Creates a UserPreferences from JSON map
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      enableLocationTracking: json['enableLocationTracking'] as bool,
      notifications: NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>),
      preferredLanguage: json['preferredLanguage'] as String,
    );
  }

  /// Converts UserPreferences to JSON map
  Map<String, dynamic> toJson() {
    return {
      'enableLocationTracking': enableLocationTracking,
      'notifications': notifications.toJson(),
      'preferredLanguage': preferredLanguage,
    };
  }

  @override
  List<Object?> get props => [enableLocationTracking, notifications, preferredLanguage];

  @override
  String toString() {
    return 'UserPreferences(locationTracking: $enableLocationTracking, '
           'notifications: $notifications, language: $preferredLanguage)';
  }
}
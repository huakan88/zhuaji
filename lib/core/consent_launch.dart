/// What the process may do before the person has chosen.
///
/// Reading the saved choice is local. Notification plugins, cloud sync and
/// barcode uploads wait until the stored value is accept.
class LaunchPlan {
  const LaunchPlan({
    required this.showConsent,
    required this.initNotifications,
    required this.syncCloud,
  });

  final bool showConsent;
  final bool initNotifications;
  final bool syncCloud;

  static const pending = LaunchPlan(
    showConsent: true,
    initNotifications: false,
    syncCloud: false,
  );

  static const basic = LaunchPlan(
    showConsent: false,
    initNotifications: false,
    syncCloud: false,
  );

  static const accepted = LaunchPlan(
    showConsent: false,
    initNotifications: true,
    syncCloud: true,
  );
}

/// `1` is accept, `0` is basic mode, anything else still needs a choice.
LaunchPlan planLaunch(String? privacyConsent) {
  return switch (privacyConsent) {
    '1' => LaunchPlan.accepted,
    '0' => LaunchPlan.basic,
    _ => LaunchPlan.pending,
  };
}

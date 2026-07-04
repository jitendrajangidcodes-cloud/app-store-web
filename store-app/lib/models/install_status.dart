import 'release_info.dart';

enum InstallState { notInstalled, upToDate, updateAvailable, unknown }

// The installed side of one app: what version is on the device (null if not
// installed), paired with the catalog's latest to produce a single state the
// UI renders as Install / Open / Update.
class InstalledInfo {
  final String? versionName;
  final int? versionCode;
  const InstalledInfo({this.versionName, this.versionCode});

  bool get isInstalled => versionName != null || versionCode != null;
}

class AppStatus {
  final InstalledInfo installed;
  final ReleaseInfo? latest;
  final InstallState state;

  const AppStatus({
    required this.installed,
    required this.latest,
    required this.state,
  });
}

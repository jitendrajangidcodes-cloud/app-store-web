import 'package:pub_semver/pub_semver.dart';

// True when `latest` is newer than `installed`. Prefers numeric versionCode
// when both sides have one (authoritative); otherwise compares semver names.
// Any parse failure is treated as "no update" so the store never nags on a
// version string it cannot understand.
bool isNewer({
  String? installedName,
  int? installedCode,
  required String latestName,
  int? latestCode,
}) {
  if (installedCode != null && latestCode != null) {
    return latestCode > installedCode;
  }
  if (installedName == null) return false;
  try {
    return Version.parse(_clean(latestName)) > Version.parse(_clean(installedName));
  } catch (_) {
    return false;
  }
}

String _clean(String v) => v.trim().replaceFirst("v", "").split("+").first;

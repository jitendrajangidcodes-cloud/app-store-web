import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../config.dart';
import '../data/version_compare.dart';
import '../models/release_info.dart';

// Checks the store's OWN GitHub Releases and reports a newer build if one
// exists. Returns null when up to date, offline, or the store repo/release does
// not exist yet -- so it fails quiet and never blocks the catalog.
class SelfUpdate {
  Future<ReleaseInfo?> check() async {
    try {
      final res = await http.get(
        Uri.parse(
            "https://api.github.com/repos/${Config.storeRepo}/releases/tags/${Config.storeTag}"),
        headers: {"Accept": "application/vnd.github+json"},
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final assets = (data["assets"] as List<dynamic>? ?? []);
      final asset = assets.cast<Map<String, dynamic>>().firstWhere(
            (a) => (a["name"] as String).endsWith(".apk"),
            orElse: () => assets.isNotEmpty
                ? assets.first as Map<String, dynamic>
                : <String, dynamic>{},
          );

      // Version lives in the release name (the tag is the stable "store"); fall
      // back to tag_name for older releases.
      final name = (data["name"] as String? ?? data["tag_name"] as String? ?? "")
          .replaceFirst("v", "");
      final parts = name.split("+");
      final latest = ReleaseInfo(
        version: parts.first,
        versionCode: parts.length > 1 ? int.tryParse(parts[1]) : null,
        notes: data["body"] as String? ?? "",
        publishedAt: data["published_at"] as String?,
        apkUrl: asset["browser_download_url"] as String?,
        sizeBytes: (asset["size"] as num?)?.toInt(),
      );
      if (latest.apkUrl == null) return null;

      final info = await PackageInfo.fromPlatform();
      final newer = isNewer(
        installedName: info.version,
        installedCode: int.tryParse(info.buildNumber),
        latestName: latest.version,
        latestCode: latest.versionCode,
      );
      return newer ? latest : null;
    } catch (_) {
      return null;
    }
  }
}

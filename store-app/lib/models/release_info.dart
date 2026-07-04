// Latest release for one app, from releases.json (generated in CI). versionCode
// is present only when the release was tagged v<name>+<code>; otherwise null and
// comparison falls back to the semver version name.
class ReleaseInfo {
  final String version;
  final int? versionCode;
  final String notes;
  final String? publishedAt;
  final String? apkUrl;
  final int? sizeBytes;

  const ReleaseInfo({
    required this.version,
    required this.versionCode,
    required this.notes,
    required this.publishedAt,
    required this.apkUrl,
    required this.sizeBytes,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> j) => ReleaseInfo(
        version: (j["version"] as String? ?? "").replaceFirst("v", ""),
        versionCode: (j["versionCode"] as num?)?.toInt(),
        notes: j["notes"] as String? ?? "",
        publishedAt: j["publishedAt"] as String?,
        apkUrl: j["apkUrl"] as String?,
        sizeBytes: (j["sizeBytes"] as num?)?.toInt(),
      );

  String get sizeLabel {
    if (sizeBytes == null) return "--";
    return "${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}

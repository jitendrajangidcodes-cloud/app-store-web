import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/app_entry.dart';
import '../models/release_info.dart';

class Catalog {
  final List<AppEntry> apps;
  final Map<String, ReleaseInfo> releases;
  const Catalog({required this.apps, required this.releases});

  ReleaseInfo? releaseFor(String appId) => releases[appId];
}

// Loads the same two files the website reads. Both live on the static site, so
// the catalog is always in step with what is published there.
class CatalogRepository {
  Future<Catalog> load() async {
    final apps = await _loadApps();
    final releases = await _loadReleases();
    return Catalog(apps: apps, releases: releases);
  }

  Future<List<AppEntry>> _loadApps() async {
    final res = await http.get(Uri.parse(Config.appsUrl));
    if (res.statusCode != 200) {
      throw Exception("apps.json ${res.statusCode}");
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => AppEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, ReleaseInfo>> _loadReleases() async {
    try {
      final res = await http.get(Uri.parse(Config.manifestUrl));
      if (res.statusCode != 200) return {};
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final apps = data["apps"] as Map<String, dynamic>? ?? {};
      return apps.map(
        (id, v) => MapEntry(id, ReleaseInfo.fromJson(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }
}

// Screenshot/icon srcs in apps.json are site-relative; resolve against the site.
String resolveAsset(String src) =>
    src.startsWith("http") ? src : "${Config.siteBase}/$src";

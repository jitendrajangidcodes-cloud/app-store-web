import '../data/catalog_repository.dart';
import '../data/version_compare.dart';
import '../models/app_entry.dart';
import '../models/install_status.dart';
import 'installer.dart';

// Computes the Install / Open / Update state for each app by pairing the
// device's installed version with the catalog's latest release.
class UpdateService {
  final Installer installer;
  UpdateService(this.installer);

  Future<AppStatus> statusFor(AppEntry app, Catalog catalog) async {
    final installed = await installer.installedInfo(app.packageId);
    final latest = catalog.releaseFor(app.id);
    return AppStatus(
      installed: installed,
      latest: latest,
      state: _state(installed, latest),
    );
  }

  Future<Map<String, AppStatus>> statusForAll(Catalog catalog) async {
    final out = <String, AppStatus>{};
    for (final app in catalog.apps) {
      out[app.id] = await statusFor(app, catalog);
    }
    return out;
  }

  InstallState _state(InstalledInfo installed, latest) {
    if (latest == null || latest.apkUrl == null) return InstallState.unknown;
    if (!installed.isInstalled) return InstallState.notInstalled;
    final newer = isNewer(
      installedName: installed.versionName,
      installedCode: installed.versionCode,
      latestName: latest.version,
      latestCode: latest.versionCode,
    );
    return newer ? InstallState.updateAvailable : InstallState.upToDate;
  }
}

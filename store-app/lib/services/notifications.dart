import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Posts "update available" notifications, the Play-Store-like nudge. Tapping one
// opens the store to the app; the actual install still needs the user's tap on
// the system installer dialog (an Android rule no third-party store bypasses).
class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = "updates";

  static Future<void> init() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showUpdates(List<String> appNames) async {
    if (appNames.isEmpty) return;
    final body = appNames.length == 1
        ? "${appNames.first} has an update ready to install"
        : "${appNames.length} apps have updates ready to install";
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        "App updates",
        channelDescription: "Notifies when a managed app has a new version",
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(1001, "Updates available", body, details);
  }
}

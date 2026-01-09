import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Bildirime tıklandı: ${response.payload}');
      },
    );

    final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelName = 'Genel Bildirimler',
    String channelDesc = 'Uygulama bildirimleri',
  }) async {

    var androidNotificationDetails =
    AndroidNotificationDetails(
      'main_channel',
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var notificationDetails =
    NotificationDetails(android: androidNotificationDetails, iOS: const DarwinNotificationDetails());

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
    required String channelDesc,
  }) async {

    await cancelDailyNotification();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    var androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      888,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Hatırlatıcı kuruldu: $hour:$minute - $title');
  }

  Future<void> cancelDailyNotification() async {
    await flutterLocalNotificationsPlugin.cancel(888);
  }
}
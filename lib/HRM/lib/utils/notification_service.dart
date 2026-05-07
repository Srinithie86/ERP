import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
        
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
        if (response.payload != null) {
          // You can add logic here to navigate to specific screens
          // For now, it will be handled via a global navigator if available
        }
      },
    );

    // Request permissions for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    // Request exact alarm permission
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _isInitialized = true;
  }

  Future<void> scheduleCheckoutReminder(DateTime checkInTime, {int shiftDurationHours = 9, int reminderBeforeMinutes = 30}) async {
    await init();
    
    // Calculate reminder time
    final DateTime checkoutTime = checkInTime.add(Duration(hours: shiftDurationHours));
    DateTime reminderTime = checkoutTime.subtract(Duration(minutes: reminderBeforeMinutes));
    
    // If the reminder time has already passed, don't schedule
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint("Reminder time already passed, not scheduling.");
      return;
    } else {
      debugPrint("Scheduling checkout reminder for: $reminderTime");
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'checkout_reminder_channel',
      'Checkout Reminders',
      channelDescription: 'Reminders for checking out from work',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1001,
      title: 'Time to Check-out Soon!',
      body: 'Your $shiftDurationHours-hour shift is almost over. Remember to check out in $reminderBeforeMinutes minutes.',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelCheckoutReminder() async {
    await init();
    await _flutterLocalNotificationsPlugin.cancel(id: 1001);
    debugPrint("Cancelled checkout reminder");
  }

  Future<void> scheduleCheckInReminder({int shiftStartHour = 9, int shiftStartMinute = 0, int reminderBeforeMinutes = 10}) async {
    await init();
    
    DateTime now = DateTime.now();
    DateTime shiftTime = DateTime(now.year, now.month, now.day, shiftStartHour, shiftStartMinute);
    DateTime reminderTime = shiftTime.subtract(Duration(minutes: reminderBeforeMinutes));
    
    if (reminderTime.isBefore(now)) {
      // If today's reminder time has passed, schedule for tomorrow
      shiftTime = shiftTime.add(const Duration(days: 1));
      reminderTime = shiftTime.subtract(Duration(minutes: reminderBeforeMinutes));
    }
    
    debugPrint("Scheduling check-in reminder for: $reminderTime");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'checkin_reminder_channel',
      'Check-in Reminders',
      channelDescription: 'Reminders for checking in to work',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1002,
      title: 'Time to Check-In!',
      body: 'Your shift starts in $reminderBeforeMinutes minutes. Please open the app and check in.',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelCheckInReminder() async {
    await init();
    await _flutterLocalNotificationsPlugin.cancel(id: 1002);
    debugPrint("Cancelled check-in reminder");
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    // Determine status for styling
    bool isApproved = title.toLowerCase().contains('approved') || body.toLowerCase().contains('approved');
    bool isRejected = title.toLowerCase().contains('rejected') || body.toLowerCase().contains('rejected');
    
    String statusPrefix = isApproved ? "✅ APPROVED: " : (isRejected ? "❌ REJECTED: " : "🔔 ");
    
    // Professional Body Formatting (simulating the image structure)
    // We try to structure the body to look cleaner
    String formattedBody = body;
    if (body.contains('|')) {
       // If we already formatted it in BackgroundFetchService
       formattedBody = body;
    } else {
       formattedBody = "📝 Status Update: $body";
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hrm_alerts_v1',
      'HRM Alerts',
      channelDescription: 'Immediate alerts for status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      color: isApproved ? const Color(0xFF4CAF50) : (isRejected ? const Color(0xFFF44336) : const Color(0xff26A69A)),
      ledColor: const Color(0xff26A69A),
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: 'HRM Status Update',
      // Using BigTextStyle to allow more content and better visibility
      styleInformation: BigTextStyleInformation(
        formattedBody,
        contentTitle: "$statusPrefix$title",
        summaryText: "HRM Status Update",
      ),
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: "$statusPrefix$title",
      body: formattedBody,
      notificationDetails: details,
      payload: payload,
    );
  }
}

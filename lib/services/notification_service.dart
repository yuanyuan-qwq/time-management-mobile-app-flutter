import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Note: Request permissions separately
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (!task.isReminderActive || task.isCompleted) {
      return;
    }

    // Schedule for due date (assuming due date is the reminder time)
    // If due date is in the past, don't schedule
    // Or schedule for 10 mins before? User didn't specify.
    // "Reminder" usually means AT the time or BEFORE.
    // Given the prompt "Task Reminder", let's assume AT due date for now.

    if (task.dueDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id: task.id,
      title: 'Task Reminder',
      body: task.title,
      scheduledDate: tz.TZDateTime.from(task.dueDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskReminder(int taskId) async {
    await _notificationsPlugin.cancel(id: taskId);
  }

  Future<void> showPomodoroComplete(String title, String body) async {
    await _notificationsPlugin.show(
      id: 99999, // Fixed ID for pomodoro, or random
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_timer',
          'Pomodoro Timer',
          channelDescription: 'Notifications for Pomodoro timer',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm_sound'), // If added
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

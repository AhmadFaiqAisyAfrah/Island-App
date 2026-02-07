import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Calm, minimal notification service for Island app.
/// Android-first, permission-safe, non-aggressive.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // SharedPreferences keys
  static const String _keyEnabled = 'notificationEnabled';
  static const String _keyPermissionAsked = 'notificationPermissionAsked';
  static const String _keyTodayFocusCount = 'todayFocusCount';
  static const String _keyLastFocusDate = 'lastFocusDate';

  // Channel configuration
  static const String _channelId = 'island_notifications';
  static const String _channelName = 'Island';
  static const String _channelDescription =
      'Gentle updates from your Island';

  // Notification IDs
  static const int _focusCompletionId = 1;
  static const int _dailyReflectionId = 2;

  static const List<String> _focusMessages = [
    'Nice work. Your island just grew 🌱',
    'A calm session completed.',
    'You stayed with your focus.',
    'Another quiet moment for your island.',
  ];

  static const List<String> _dailyReflectionMessages = [
    'A quiet day. Your island rests tonight.',
    'Today mattered. Thank you for showing up.',
    'Your island remembers today 🌙',
    'A gentle close to a focused day.',
  ];

  /// Initialize notification service (call once in main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    
    _prefs = await SharedPreferences.getInstance();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;

    if (kDebugMode) {
      print('NotificationService initialized');
    }
  }

  /// Check current system notification permission status
  Future<bool> checkPermissionStatus() async {
    await init();

    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission from the system
  /// Returns true if granted, false if denied
  Future<bool> requestPermission() async {
    await init();

    // Request permission using permission_handler
    final status = await Permission.notification.request();
    
    await _savePermissionAskedState(true);
    await _saveEnabledState(status.isGranted);

    return status.isGranted;
  }

  /// Open system app settings for this app
  /// User can manually enable notifications there
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  /// Enable notifications (only if system allows)
  Future<bool> enable() async {
    final allowed = await checkPermissionStatus();
    if (!allowed) return false;

    await _saveEnabledState(true);
    return true;
  }

  /// Disable notifications
  Future<void> disable() async {
    await _saveEnabledState(false);
    await cancelAll();
  }

  /// Set notification enabled state with permission check
  /// If enabling and permission not granted, returns false
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      return await enable();
    } else {
      await disable();
      return true;
    }
  }

  /// Check if notifications are enabled (user preference)
  Future<bool> isEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_keyEnabled) ?? false;
  }

  /// Show focus-completed notification
  /// Only shows if system permission granted AND user preference enabled
  Future<void> showFocusCompleted() async {
    if (!_isInitialized) return;

    final userEnabled = await isEnabled();
    final systemAllowed = await checkPermissionStatus();

    if (!userEnabled || !systemAllowed) return;

    final message =
        _focusMessages[Random().nextInt(_focusMessages.length)];

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      showWhen: false,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      _focusCompletionId,
      'Island',
      message,
      details,
    );
  }

  // ========================
  // Daily Reflection Notification
  // ========================

  /// Schedule daily reflection notification at 23:55
  /// Only schedules if all conditions are met:
  /// - User enabled notifications
  /// - System permission granted  
  /// - Today has ≥1 focus session
  Future<void> scheduleDailyReflection() async {
    if (!_isInitialized) return;

    // Check all conditions
    final userEnabled = await isEnabled();
    final systemAllowed = await checkPermissionStatus();
    final todayCount = await getTodayFocusCount();

    if (!userEnabled || !systemAllowed || todayCount < 1) {
      // Cancel any existing scheduled notification if conditions not met
      await cancelDailyReflection();
      return;
    }

    // Get local timezone
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    
    // Schedule for 23:55 today (or tomorrow if already past)
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      23,
      55,
    );
    
    // If it's already past 23:55, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final message = _dailyReflectionMessages[
        Random().nextInt(_dailyReflectionMessages.length)];

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      showWhen: false,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _dailyReflectionId,
      'Island',
      message,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      print('Daily reflection scheduled for $scheduledDate');
    }
  }

  /// Cancel the daily reflection notification
  Future<void> cancelDailyReflection() async {
    await _notifications.cancel(_dailyReflectionId);
    
    if (kDebugMode) {
      print('Daily reflection cancelled');
    }
  }

  /// Reschedule daily reflection if conditions changed
  /// Call this when:
  /// - App starts
  /// - Focus session completes
  /// - Notification settings change
  Future<void> rescheduleDailyReflectionIfNeeded() async {
    // Cancel existing notification first
    await cancelDailyReflection();
    
    // Check if we should schedule
    final userEnabled = await isEnabled();
    final systemAllowed = await checkPermissionStatus();
    final todayCount = await getTodayFocusCount();

    if (userEnabled && systemAllowed && todayCount > 0) {
      await scheduleDailyReflection();
    }
  }

  // ========================
  // Focus Session Tracking
  // ========================

  /// Increment today's focus session count
  /// Call this when a focus session completes
  Future<void> incrementTodayFocusCount() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // Check if we need to reset (new day)
    final lastDate = _prefs!.getString(_keyLastFocusDate) ?? '';
    if (lastDate != todayString) {
      // New day - reset count
      await _prefs!.setString(_keyLastFocusDate, todayString);
      await _prefs!.setInt(_keyTodayFocusCount, 1);
    } else {
      // Same day - increment count
      final currentCount = _prefs!.getInt(_keyTodayFocusCount) ?? 0;
      await _prefs!.setInt(_keyTodayFocusCount, currentCount + 1);
    }
    
    if (kDebugMode) {
      print('Focus count incremented for $todayString');
    }
  }

  /// Get today's focus session count
  Future<int> getTodayFocusCount() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastDate = _prefs!.getString(_keyLastFocusDate) ?? '';
    
    // If it's a new day, return 0 (count resets automatically on next increment)
    if (lastDate != todayString) {
      return 0;
    }
    
    return _prefs!.getInt(_keyTodayFocusCount) ?? 0;
  }

  // ========================
  // DEBUG HELPERS
  // ========================

  /// DEBUG ONLY: Schedule a test daily reflection notification
  /// Fires after the specified delay
  Future<void> scheduleDailyReflectionTest(Duration delay) async {
    if (!_isInitialized) return;

    if (kDebugMode) {
      print('DEBUG: Scheduling test reflection in ${delay.inSeconds}s');
    }

    final location = tz.local;
    final scheduledDate = tz.TZDateTime.now(location).add(delay);

    final message = _dailyReflectionMessages[
        Random().nextInt(_dailyReflectionMessages.length)];

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      showWhen: false,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _dailyReflectionId,
      'Island',
      '[TEST] $message',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (kDebugMode) {
      print('DEBUG: Test reflection scheduled for $scheduledDate');
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // ========================
  // Preferences helpers
  // ========================

  Future<void> _saveEnabledState(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyEnabled, enabled);
  }

  Future<void> _savePermissionAskedState(bool asked) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyPermissionAsked, asked);
  }

  Future<bool> permissionAsked() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_keyPermissionAsked) ?? false;
  }
}

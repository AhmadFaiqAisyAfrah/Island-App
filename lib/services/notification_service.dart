import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Channel configuration
  static const String _channelId = 'island_notifications';
  static const String _channelName = 'Island';
  static const String _channelDescription =
      'Gentle updates from your Island';

  static const List<String> _focusMessages = [
    'Nice work. Your island just grew 🌱',
    'A calm session completed.',
    'You stayed with your focus.',
    'Another quiet moment for your island.',
  ];

  /// Initialize notification service (call once in main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

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
      1,
      'Island',
      message,
      details,
    );
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

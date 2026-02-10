import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    // Check both user preference AND actual system permission
    final userEnabled = await NotificationService().isEnabled();
    final systemAllowed = await NotificationService().checkPermissionStatus();
    
    // Only show as enabled if both user wants it AND system allows it
    setState(() {
      _notificationsEnabled = userEnabled && systemAllowed;
      _permissionChecked = true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // User wants to enable notifications
      // First check if system permission is granted
      final hasSystemPermission = await NotificationService().checkPermissionStatus();
      
      if (hasSystemPermission) {
        // Permission already granted, just enable
        await NotificationService().setEnabled(true);
        setState(() {
          _notificationsEnabled = true;
        });
      } else {
        // No system permission - request it
        final granted = await NotificationService().requestPermission();
        
        if (granted) {
          // Permission granted after request
          setState(() {
            _notificationsEnabled = true;
          });
        } else {
          // Permission denied - open system settings
          setState(() {
            _notificationsEnabled = false;
          });
          _showPermissionDeniedDialog();
        }
      }
    } else {
      // Disable notifications
      await NotificationService().setEnabled(false);
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.skyBottom,
        title: Text(
          'Notifications Disabled',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        content: Text(
          'You can enable notifications anytime in system settings.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: AppColors.textMain.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(color: AppColors.islandGrass),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    // Open app notification settings using permission_handler
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTextStyles.heading.copyWith(fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: AppTextStyles.subHeading.copyWith(
                  fontSize: 16,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                     Text(
                       '\ud83d\udd14', // 🔔
                       style: TextStyle(
                         fontSize: 20, // Ukuran sejajar dengan teks
                         height: 1.0, // Tinggi disesuaikan
                       ),
                     ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: AppTextStyles.subHeading.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Gentle updates from Island',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              color: AppColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_permissionChecked)
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: AppColors.islandGrass,
                      )
                    else
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

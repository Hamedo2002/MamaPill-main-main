import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mama_pill/core/presentation/widgets/custom_back_button.dart';
import 'package:mama_pill/core/presentation/widgets/setting_item.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/services/local_notification_services.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/core/presentation/view/pin_setup_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.authBloc});
  final AuthBloc authBloc;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  (IconData, Color) _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.doctor:
        return (Icons.medical_information, Colors.blue);
      case UserRole.staff:
        return (Icons.medical_information_rounded, Colors.teal);
      case UserRole.patient:
        return (Icons.personal_injury_rounded, Colors.orange);
      default:
        return (Icons.person_outlined, Colors.grey);
    }
  }

  bool _notificationsEnabled = true;
  bool _pinEnabled = false;

  static const String _notificationsKey = 'notifications_enabled';
  static const String _pinEnabledKey = 'pin_enabled';

  // Initialize with default values to avoid LateInitializationError
  late AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );
  late Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
  );

  @override
  void initState() {
    super.initState();

    _loadNotificationState();
    _loadPinState();

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getBool(_notificationsKey) ?? true;
    setState(() {
      _notificationsEnabled = savedState;
    });
    if (!savedState) {
      await LocalNotificationServices.notification.cancelAll();
    }
  }

  Future<void> _saveNotificationState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> _loadPinState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
    });
  }

  Future<void> _togglePin() async {
    if (!_pinEnabled) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupView()),
      );
      if (result == true) {
        setState(() => _pinEnabled = true);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pinEnabledKey, false);
      await prefs.remove('app_pin');
      setState(() => _pinEnabled = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      bool? permission;

      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            LocalNotificationServices.notification
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        permission =
            await androidImplementation?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
            LocalNotificationServices.notification
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();
        permission = await iOSImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      setState(() {
        _notificationsEnabled = permission ?? false;
      });

      if (permission == true) {
        // Reinitialize notifications with full initialization
        await LocalNotificationServices.init(initSchedule: true);
      }
    } else {
      // Cancel all notifications and clear any pending schedules
      await LocalNotificationServices.notification.cancelAll();

      // Also cancel any scheduled notifications
      final pendingNotifications =
          await LocalNotificationServices.notification
              .pendingNotificationRequests();
      for (var notification in pendingNotifications) {
        await LocalNotificationServices.notification.cancel(notification.id);
      }

      // Clear any stored notification data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);

      setState(() {
        _notificationsEnabled = false;
      });
    }
    await _saveNotificationState(_notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium!.copyWith(
      fontSize: 22.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
    final UserProfile user = widget.authBloc.state.user;
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary.withOpacity(0.97),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: AppHeight.h50.h,
        title: Text('Settings', style: titleStyle),
        centerTitle: true,
        leading: const CustomBackButton(),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28.h),
                _accountSettings(user, context),
                SizedBox(height: 36.h),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    'Preferences',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _settingsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _accountSettings(UserProfile user, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Get the actual username from the user profile
    // If username is null or empty, try to use email (up to @ symbol) as fallback
    String displayName;
    if (user.username != null && user.username!.isNotEmpty) {
      displayName = user.username!;
    } else if (user.email != null && user.email!.isNotEmpty) {
      // Extract name from email (part before @)
      displayName = user.email!.split('@')[0];
      // Capitalize first letter
      if (displayName.isNotEmpty) {
        displayName = displayName[0].toUpperCase() + displayName.substring(1);
      }
    } else {
      // Final fallback
      displayName = 'User';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 22.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getRoleIcon(user.role).$2.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: AppSize.s24.r,
              backgroundColor: _getRoleIcon(user.role).$2.withOpacity(0.15),
              child: Icon(
                _getRoleIcon(user.role).$1,
                color: _getRoleIcon(user.role).$2,
                size: 28.r,
              ),
            ),
          ),
          SizedBox(width: AppWidth.w20.w),
          Text(
            displayName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Container _settingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              leading: Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 26.r,
              ),
              title: Text(
                'Notifications',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.5),
                inactiveThumbColor: Colors.transparent,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            indent: AppWidth.w52.w,
            endIndent: 20.w,
            color: AppColors.divider.withOpacity(0.2),
          ),
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _togglePin,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: const Color(0xFF4CAF50),
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'PIN Security',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4CAF50),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF4CAF50),
                          size: 24.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0,
                thickness: 1,
                indent: AppWidth.w52.w,
                endIndent: 20.w,
                color: AppColors.divider.withOpacity(0.2),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: SettingItem(
              label: 'Logout',
              icon: Icons.logout_outlined,
              onTap: () => widget.authBloc.add(AuthLogoutRequested()),
              color: Colors.red,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }
}

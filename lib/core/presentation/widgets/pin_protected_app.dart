import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mama_pill/core/presentation/view/pin_verify_view.dart';

class PinProtectedApp extends StatefulWidget {
  const PinProtectedApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PinProtectedApp> createState() => _PinProtectedAppState();
}

class _PinProtectedAppState extends State<PinProtectedApp> with WidgetsBindingObserver {
  bool _isLocked = false;
  static const String pinEnabledKey = 'pin_enabled';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPinEnabled();
  }

  Future<void> _checkPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final pinEnabled = prefs.getBool(pinEnabledKey) ?? false;
    final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    if (pinEnabled && isAuthenticated) {
      setState(() => _isLocked = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      final prefs = await SharedPreferences.getInstance();
      final pinEnabled = prefs.getBool(pinEnabledKey) ?? false;
      if (pinEnabled) {
        setState(() => _isLocked = true);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PinVerifyView(
          onPinVerified: () {
            setState(() => _isLocked = false);
          },
        ),
      );
    }
    return widget.child;
  }
}

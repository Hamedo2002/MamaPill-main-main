import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mama_pill/core/presentation/widgets/custom_back_button.dart';

class PinSetupView extends StatefulWidget {
  const PinSetupView({super.key});

  @override
  State<PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<PinSetupView> with SingleTickerProviderStateMixin {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  String _errorMessage = '';
  static const String pinKey = 'app_pin';
  static const String pinEnabledKey = 'pin_enabled';
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_isConfirming) {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin.add(digit);
          _errorMessage = '';
        });
        if (_confirmPin.length == 4) {
          _verifyPin();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() {
          _pin.add(digit);
          _errorMessage = '';
        });
        if (_pin.length == 4) {
          setState(() => _isConfirming = true);
        }
      }
    }
  }

  void _removeDigit() {
    setState(() {
      if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin.removeLast();
      } else if (!_isConfirming && _pin.isNotEmpty) {
        _pin.removeLast();
      }
      _errorMessage = '';
    });
  }

  Future<void> _verifyPin() async {
    if (_pin.join() != _confirmPin.join()) {
      _animationController.forward().then((_) => _animationController.reverse());
      setState(() {
        _errorMessage = 'PINs do not match';
        _confirmPin.clear();
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pinKey, _pin.join());
    await prefs.setBool(pinEnabledKey, true);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildPinDot(bool filled) {
    return Container(
      width: 16.w,
      height: 16.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        color: filled ? const Color(0xFF4CAF50) : Colors.transparent,
      ),
    );
  }

  Widget _buildKeypadButton(String value, {bool isIcon = false, double? size}) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isIcon) {
              _removeDigit();
            } else {
              _addDigit(value);
            }
          },
          borderRadius: BorderRadius.circular(size ?? 0),
          child: Center(
            child: isIcon
                ? Icon(
                    Icons.close,
                    color: const Color(0xFF4CAF50),
                    size: 24.r,
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          'Set PIN',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: const Color(0xFF4CAF50),
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _isConfirming
                          ? 'Confirm your PIN'
                          : 'Create a 4-digit PIN to secure\nyour app',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF4CAF50),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 16.h),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => _buildPinDot(index < currentPin.length),
              ),
            ),
            SizedBox(height: 40.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonSize = (constraints.maxWidth - 32.w) / 3;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('1', size: buttonSize),
                            _buildKeypadButton('2', size: buttonSize),
                            _buildKeypadButton('3', size: buttonSize),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('4', size: buttonSize),
                            _buildKeypadButton('5', size: buttonSize),
                            _buildKeypadButton('6', size: buttonSize),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('7', size: buttonSize),
                            _buildKeypadButton('8', size: buttonSize),
                            _buildKeypadButton('9', size: buttonSize),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: buttonSize),
                            _buildKeypadButton('0', size: buttonSize),
                            _buildKeypadButton('', size: buttonSize, isIcon: true),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

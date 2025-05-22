import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomSheetUtils {
  static Future<void> showButtomSheet(BuildContext context, Widget child) async {
    // Use a delayed future to ensure we're not in the middle of a build
    await Future.delayed(Duration.zero);
    if (context.mounted) {
      await showModalBottomSheet(
        enableDrag: true,
        isDismissible: true,
        isScrollControlled: true,
        useRootNavigator: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Wrap(
                children: [child],
              ),
            ),
          );
        },
      );
    }
  }
}

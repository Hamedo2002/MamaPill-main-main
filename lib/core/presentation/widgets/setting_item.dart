import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.color = AppColors.textPrimary,
    this.isLast = false,
    this.trailing,
    this.subtitle,
  });
  final String label;
  final IconData icon;
  final Function()? onTap;
  final Color color;
  final bool isLast;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
        onTap: onTap,
        child: Column(
          children: [
            ListTile(
              visualDensity: VisualDensity.compact,
              minLeadingWidth: 0,
              minVerticalPadding: 0,
              leading: Icon(icon, color: color),
              title: Text(label,
                  style: textTheme.bodyMedium!.copyWith(color: color)),
              subtitle: subtitle != null
                  ? Text(subtitle!,
                      style: textTheme.bodySmall!.copyWith(
                          color: color.withOpacity(0.7)))
                  : null,
              trailing: trailing ?? (onTap != null
                  ? Icon(Icons.arrow_forward_ios,
                      size: AppSize.s16.sp, color: color)
                  : null),
            ),
            if (!isLast)
              Divider(
                height: 0,
                thickness: 1,
                indent: AppWidth.w52.w,
                color: AppColors.divider.withOpacity(0.2),
              ),
          ],
        ));
  }
}


// Container(
//         // margin: const EdgeInsets.only(left: p16).w,
//         padding: const EdgeInsets.fromLTRB(0, p16, p16, p16).w,
//         decoration: BoxDecoration(
//           border: isLast
//               ? null
//               : Border(
//                   bottom:
//                       BorderSide(color: AppColors.divider.withOpacity(0.5))),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color),
//             SizedBox(width: AppWidth.w16.w),
//             Text(label, style: textTheme.bodyMedium!.copyWith(color: color)),
//             const Spacer(),
//             Icon(Icons.arrow_forward_ios, size: AppSize.s16.sp, color: color),
//           ],
//         ),
//       ),
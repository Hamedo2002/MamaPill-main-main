import 'package:flutter/material.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';

extension MedicineTypeX on MedicineType {
  String get name {
    switch (this) {
      case MedicineType.tablet:
        return 'tablet';
      case MedicineType.capsule:
        return 'capsule';
      case MedicineType.liquid:
        return 'liquid';
      case MedicineType.injection:
        return 'injection';
    }
  }

  String get shortName {
    switch (this) {
      case MedicineType.tablet:
        return 'tab';
      case MedicineType.capsule:
        return 'cap';
      case MedicineType.liquid:
        return 'liq';
      case MedicineType.injection:
        return 'inj';
    }
  }

  String get icon {
    switch (this) {
      case MedicineType.tablet:
        return AppAssets.tablet;
      case MedicineType.capsule:
        return AppAssets.capsule;
      case MedicineType.liquid:
        return AppAssets.liquid;
      case MedicineType.injection:
        return AppAssets.injection;
    }
  }

  Color get color {
    switch (this) {
      case MedicineType.tablet:
        return Colors.orange;
      case MedicineType.capsule:
        return Colors.blue;
      case MedicineType.liquid:
        return Colors.red;
      case MedicineType.injection:
        return Colors.brown;
    }
  }
}

class Values {
  static getIntakePerWeek(
      int intakePerDose, int intakePerDay, int daysPerWeek, {int weeksCount = 1}) {
    return intakePerDose * intakePerDay * daysPerWeek * weeksCount;
  }
}

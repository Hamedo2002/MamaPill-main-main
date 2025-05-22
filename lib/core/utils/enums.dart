enum AppStatus {
  initial,
  loading,
  success,
  error,
  authenticated,
  unauthenticated,
}

enum RequestStatus {
  initial,
  loading,
  success,
  failure,
}

enum UserRole {
  doctor,
  staff,
  patient,
}

enum MedicineType { capsule, tablet, liquid, injection }

enum MedicineStatus { pending, taken, skipped }

enum AuthStatus { initial, submiting, success, failure }

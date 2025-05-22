import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_pill/features/authentication/domain/repositories/auth_repository.dart';

class GetUserProfileUseCase {
  GetUserProfileUseCase(this.authRepository);
  final AuthRepository authRepository;

  Future<User?> call() async {
    try {
      return await authRepository.getUserProfile();
    } catch (_) {
      return null;
    }
  }
}

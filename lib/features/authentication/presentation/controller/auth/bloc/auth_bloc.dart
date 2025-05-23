import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mama_pill/core/domain/usecase/usecase.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/domain/usecases/get_user_profile_usecase.dart';
import 'package:mama_pill/features/authentication/domain/usecases/user_state_change_usecase.dart';
import 'package:mama_pill/features/authentication/domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogoutUseCase logoutUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UserStateChangeUseCase userStateChangeUseCase;

  late final StreamSubscription<User?> userStateSubscription;

  AuthBloc(
    this.logoutUseCase,
    this.getUserProfileUseCase,
    this.userStateChangeUseCase,
  ) : super(const AuthState()) {
    on<AuthChecked>(_onAuthChecked);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<UserProfileFetched>(_onUserProfileFetched);

    userStateSubscription = userStateChangeUseCase().listen((user) {
      add(AuthChecked(user));
      if (user != null) {
        add(UserProfileFetched());
      }
    });
  }

  Future<FutureOr<void>> _onAuthChecked(
      AuthChecked event, Emitter<AuthState> emit) async {
    User? user = event.user;
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setBool('is_authenticated', true);
      emit(state.copyWith(status: AppStatus.authenticated));
    } else {
      await prefs.setBool('is_authenticated', false);
      emit(state.copyWith(status: AppStatus.unauthenticated));
    }
  }

  Future<FutureOr<void>> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await logoutUseCase(const NoParams());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', false);
      emit(state.copyWith(
          status: AppStatus.unauthenticated, user: const UserProfile.empty()));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUserProfileFetched(
      UserProfileFetched event, Emitter<AuthState> emit) async {
    try {
      User? user = await getUserProfileUseCase();
      if (user != null) {
        // Get user role from Firestore
        print('Getting user role for uid: ${user.uid}');
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        print('Raw Firestore data: ${userData.data()}');

        UserRole role = UserRole.patient; // Default role
        String? patientId;

        if (userData.exists) {
          final data = userData.data() as Map<String, dynamic>;
          print('Raw Firestore data: $data');
          final roleStr = (data['role'] as String).toLowerCase();
          print('Raw role string from Firestore: $roleStr');

          // Get patient ID if it exists
          patientId = data['patientId'] as String?;
          print('Patient ID from Firestore: $patientId');

          // Convert role string to enum
          switch (roleStr) {
            case 'doctor':
              role = UserRole.doctor;
              break;
            case 'staff':
              role = UserRole.staff;
              break;
            case 'patient':
              role = UserRole.patient;
              break;
            default:
              print('Unknown role: $roleStr, defaulting to patient');
              role = UserRole.patient;
          }

          print('User role from Firestore: $roleStr, parsed as: ${role.name}');
        } else {
          print('No user data found in Firestore');
          // Create user data if it doesn't exist
          final defaultData = {
            'email': user.email,
            'username': user.displayName,
            'role': role.name.toLowerCase(),
            'createdAt': FieldValue.serverTimestamp(),
          };

          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set(defaultData);
            print('Created new user data: $defaultData');
          } catch (e) {
            print('Error creating user data: $e');
            // Don't throw here, just continue with default role
          }
        }

        final userProfile = UserProfile(
          id: user.uid,
          email: user.email,
          username: user.displayName,
          role: role,
          patientId: patientId,
        );

        print('Setting user profile:');
        print('- Role: ${userProfile.role.name}');
        print('- Patient ID: ${userProfile.patientId}');
        print('- User ID: ${userProfile.id}');
        print('- Email: ${userProfile.email}');
        print('- Username: ${userProfile.username}');

        emit(
          state.copyWith(
            status: AppStatus.authenticated,
            user: userProfile,
          ),
        );
      } else {
        print('No user found from getUserProfileUseCase');
        emit(state.copyWith(
            status: AppStatus.unauthenticated,
            user: const UserProfile.empty()));
      }
    } catch (e) {
      print('Error in _onUserProfileFetched: $e');
      // Don't update the user profile on error, just set the error state
      emit(state.copyWith(
        status: AppStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<String?> getCurrentUserId() async {
    final user = await getUserProfileUseCase();
    return user?.uid;
  }
}

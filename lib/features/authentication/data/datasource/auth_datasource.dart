import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_pill/core/data/error/exceptions.dart';
import 'package:mama_pill/core/data/remote/network_connection.dart';
import 'package:mama_pill/core/utils/enums.dart';

abstract class AuthDataSource {
  Future<User> getUserProfile();
  Stream<User?> userChangeState();
  Future<Unit> signInWithEmailAndPassword(String email, String password);
  Future<Unit> createUserWithEmailAndPassword(
      String email, String password, String username, UserRole role,
      {String? patientId});
  Future<Unit> signOut();
}

class AuthDataSourceImpl implements AuthDataSource {
  AuthDataSourceImpl(
    this.firebaseAuth,
    this.networkConnection,
  ) {
    _usersCollection = FirebaseFirestore.instance.collection('users');
  }
  final FirebaseAuth firebaseAuth;
  final NetworkConnection networkConnection;
  late final CollectionReference _usersCollection;

  @override
  Future<User> getUserProfile() async {
    final user = firebaseAuth.currentUser!;
    await user.reload();
    return user;
  }

  @override
  Stream<User?> userChangeState() {
    firebaseAuth.currentUser?.reload();
    return firebaseAuth.authStateChanges();
  }

  @override
  Future<Unit> createUserWithEmailAndPassword(
      String email, String password, String username, UserRole role,
      {String? patientId}) async {
    try {
      final userCred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = userCred.user!;
      await user.updateDisplayName(username);
      print('Setting user role to: ${role.name}');
      // Get existing user data if any
      final existingData = await _usersCollection.doc(user.uid).get();
      print('Existing user data: ${existingData.data()}');

      final userData = {
        'email': email,
        'username': username,
        'role': role.name.toLowerCase(), // Always store as lowercase
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add patient ID if provided and role is patient
      if (role == UserRole.patient && patientId != null) {
        userData['patientId'] = patientId;
      }

      await _usersCollection.doc(user.uid).set(userData);

      // Verify the data was set correctly
      final savedData = await _usersCollection.doc(user.uid).get();
      print('Successfully set user data in Firestore: ${savedData.data()}');

      return unit;
    } catch (e) {
      print('Error creating user: $e');
      throw AuthenticationException();
    }
  }

  @override
  Future<Unit> signInWithEmailAndPassword(String email, String password) async {
    return await getFirebaseService(
      firebaseAuth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  @override
  Future<Unit> signOut() async {
    return await getFirebaseService(firebaseAuth.signOut());
  }

  Future<Unit> getFirebaseService(Future<void> function) async {
    try {
      await function;
      return Future.value(unit);
    } on FirebaseException catch (_) {
      throw AuthenticationException();
    } catch (_) {
      throw UnexpectedException();
    }
  }
}

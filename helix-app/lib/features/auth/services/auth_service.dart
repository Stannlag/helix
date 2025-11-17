import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';

/// Authentication Service using Firebase and Google Sign-In
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Is user signed in
  bool get isSignedIn => currentUser != null;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Create new user document
      final newUser = UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

      await userRef.set(newUser.toFirestore());
    } else {
      // Update existing user document (in case profile changed)
      await userRef.update({
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
      });
    }
  }

  /// Get user document from Firestore
  Future<UserModel?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Delete account (optional - for future use)
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) return;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for user document
final userDocumentProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);

  final authService = ref.watch(authServiceProvider);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
});

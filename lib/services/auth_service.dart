// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Google Sign-In FirebaseAuth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Email Sign-In Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Create account with Email and Password
  Future<UserCredential?> createUserWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Create User Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Fetch sign-in methods for email
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      return await _auth.fetchSignInMethodsForEmail(email);
    } on FirebaseAuthException catch (e) {
      print('Fetch Sign-In Methods Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Link Google account to current user
  Future<UserCredential?> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-current-user');

      return await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Link Google Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Link email/password to current user
  Future<UserCredential?> linkWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final user = _auth.currentUser;

      if (user == null) throw FirebaseAuthException(code: 'no-current-user');

      return await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Link Email/Password Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Unlink provider from current user
  Future<User?> unlinkProvider(String providerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-current-user');

      return await user.unlink(providerId);
    } on FirebaseAuthException catch (e) {
      print('Unlink Provider Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Get linked providers for current user
  List<String> getLinkedProviders() {
    final user = _auth.currentUser;
    if (user == null) return [];

    return user.providerData.map((info) => info.providerId).toList();
  }

  // Check if user has specific provider linked
  bool hasProviderLinked(String providerId) {
    return getLinkedProviders().contains(providerId);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Sign Out Error: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password Reset Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Reauthenticate user with password
  Future<UserCredential?> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(code: 'no-current-user');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      return await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Reauthenticate Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-current-user');

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      print('Update Password Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Maps a [FirebaseAuthException] to a friendly, human-readable message.
  static String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      // ── Network ──────────────────────────────────────────────────────────
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';

      // ── Login errors ─────────────────────────────────────────────────────
      case 'user-not-found':
        return 'No account found for that email. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
      // Firebase v10+ collapses user-not-found + wrong-password into this
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment before trying again.';

      // ── Sign-up errors ───────────────────────────────────────────────────
      case 'email-already-in-use':
        return 'This email is already registered. Please log in instead.';
      case 'invalid-email':
        return 'The email address is not valid. Please enter a correct email.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';

      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }

  /// Signs in with the provided [email] and [password].
  /// Returns null on success, or a friendly error message on failure.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Signs up with the provided [email] and [password].
  /// Returns null on success, or a friendly error message on failure.
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the current user.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

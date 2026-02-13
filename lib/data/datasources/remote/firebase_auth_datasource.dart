import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/exceptions.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth;
  FirebaseAuthDatasource({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try { return await _auth.signInWithEmailAndPassword(email: email, password: password); }
    on FirebaseAuthException catch (e) { throw AuthException(message: e.message ?? '로그인 실패', code: e.code); }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try { return await _auth.createUserWithEmailAndPassword(email: email, password: password); }
    on FirebaseAuthException catch (e) { throw AuthException(message: e.message ?? '회원가입 실패', code: e.code); }
  }

  Future<void> signOut() => _auth.signOut();
  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email);
}

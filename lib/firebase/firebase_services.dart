import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutternotificationserviceapp/firebase/firebase_exception.dart';
import 'package:flutternotificationserviceapp/mixins/error_handler.dart';

class FirebaseService with ErrorHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResult> signIn({String email, String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw FirebaseException(getLoginErrorMessage(e));
    }
  }

  Future<AuthResult> signUp({String email, String password}) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw FirebaseException(getErrorMessageByCode(e.code));
    }
  }

  void signOut() async {
    await _auth.signOut();
  }

  Future<FirebaseUser> getCurrentUser() async {
    return await _auth.currentUser();
  }
}

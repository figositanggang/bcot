import 'package:bcot/models/user_model.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthHelper {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  // ! Sign In With Email & Password
  static Future<String> signIn({
    required String email,
    required String password,
    required UserProvider userProvider,
  }) async {
    String res = '';

    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userSnapshot = await _firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      userProvider.user = UserModel.fromSnapshot(userSnapshot);

      res = 'success';
    } on FirebaseAuthException catch (e) {
      print(e.code);
      res = e.code;
    }

    return res;
  }

  // ! Sign Up With Email & Password
  static Future<String> signUp({
    required String email,
    required String username,
    required String name,
    required String password,
    required String photoUrl,
  }) async {
    late UserCredential userCredential;
    String res = '';

    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firebaseFirestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(
              UserModel(
                userId: userCredential.user!.uid,
                email: email,
                username: username,
                name: name,
                photoUrl: photoUrl,
              ).toMap(),
            );
      }

      res = 'success';
    } on FirebaseAuthException catch (e) {
      res = e.code;
    }

    return res;
  }

  // ! Sign Out
  static Future<void> signOut(UserProvider userProvider) async {
    try {
      await _firebaseAuth.signOut();

      userProvider.user = null;
    } catch (e) {}
  }
}

import 'package:bcot/models/bcot_model.dart';
import 'package:bcot/models/comment_model.dart';
import 'package:bcot/models/user_model.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreHelper {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  // ! Add BCot
  static Future<void> AddBcot({
    required String bcot_text,
    required String userId,
  }) async {
    late DocumentReference bcotRef;

    try {
      // ! add bcot to firestore
      bcotRef = await _firebaseFirestore.collection("bcots").add(
            BCotModel(
              bcotId: "",
              userId: userId,
              bcot_text: bcot_text,
              likes: [],
              created_at: Timestamp.fromDate(DateTime.now()),
            ).toMap(),
          );

      await bcotRef.update({"bcotId": bcotRef.id});
    } on FirebaseException catch (_) {
      // ! delete if failed
      await bcotRef.delete();
    }
  }

  // ! Remove Bcot
  static Future<void> RemoveBcot(String bcotId) async {
    try {
      await _firebaseFirestore.collection("bcots").doc(bcotId).delete();
      QuerySnapshot commentSnapshots = await _firebaseFirestore
          .collection("bcots")
          .doc(bcotId)
          .collection("comments")
          .get();

      for (var doc in commentSnapshots.docs) {
        CommentModel comment = CommentModel.fromSnapshot(doc);

        await _firebaseFirestore
            .collection("bcots")
            .doc(bcotId)
            .collection("comments")
            .doc(comment.commentId)
            .delete();
      }
    } catch (e) {}
  }

  // ! Stream All Users
  static streamUsers() {
    return _firebaseFirestore.collection("users").snapshots();
  }

  // ! Get User
  static Future<DocumentSnapshot<Map<String, dynamic>>> GetUser(String userId) {
    return _firebaseFirestore.collection("users").doc(userId).get();
  }

  // ! Get Other User
  static Future<void> GetCurrentUser({
    required String currentUserId,
    required UserProvider userProvider,
  }) async {
    DocumentSnapshot userSnapshot =
        await _firebaseFirestore.collection("users").doc(currentUserId).get();

    userProvider.user = UserModel.fromSnapshot(userSnapshot);

    await Future.delayed(Duration(seconds: 1));
  }

  // ! Like/Unlike Bcot
  static Future<String> LikeUnlikeBcot({
    required String bcotId,
    required String userId,
  }) async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("bcots").doc(bcotId).get();

    final bcot = BCotModel.fromSnapshot(snapshot);

    List likes = bcot.likes;

    if (!likes.contains(userId)) {
      likes.add(userId);
    } else {
      likes.remove(userId);
    }

    try {
      await _firebaseFirestore
          .collection("bcots")
          .doc(bcotId)
          .update({"likes": likes});

      return "success";
    } on FirebaseException catch (e) {
      print("ERROR LIKE $e");

      return "error";
    }
  }

  // ! Query Get Bcot
  static Query<Map<String, dynamic>> GetBcotQuery() {
    return _firebaseFirestore
        .collection("bcots")
        .orderBy("created_at", descending: true);
  }

  // ! Get BCot Likes
  static Stream<DocumentSnapshot<Map<String, dynamic>>> StreamBcotLikes(
      String bcotId) {
    return _firebaseFirestore.collection("bcots").doc(bcotId).snapshots();
  }

  // ! Add Comment
  static Future AddComment({
    required String bcotId,
    required String userId,
    required String commentText,
  }) async {
    try {
      DocumentReference ref = await _firebaseFirestore
          .collection("bcots")
          .doc(bcotId)
          .collection("comments")
          .add(
            CommentModel(
              commentId: "",
              userId: userId,
              commentText: commentText,
              createdAt: Timestamp.now(),
              likes: [],
            ).toMap(),
          );

      await _firebaseFirestore
          .collection("bcots")
          .doc(bcotId)
          .collection("comments")
          .doc(ref.id)
          .update({"commentId": ref.id});
    } on FirebaseException catch (_) {}
  }

  // ! Get BCot Comments Length
  static Future<QuerySnapshot<Map<String, dynamic>>> GetComments(
      String bcotId) {
    return _firebaseFirestore
        .collection("bcots")
        .doc(bcotId)
        .collection("comments")
        .orderBy("createdAt", descending: true)
        .get();
  }

  // ! Get BCot Comments Length
  static Stream<QuerySnapshot<Map<String, dynamic>>> StreamComments(
      String bcotId) {
    return _firebaseFirestore
        .collection("bcots")
        .doc(bcotId)
        .collection("comments")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ! Remove Comment
  static Future<void> RemoveComment({
    required String bcotId,
    required String commentId,
  }) async {
    try {
      await _firebaseFirestore
          .collection("bcots")
          .doc(bcotId)
          .collection("comments")
          .doc(commentId)
          .delete();
    } catch (e) {}
  }

  // ! Get Comment Likes
  static Stream<DocumentSnapshot<Map<String, dynamic>>> GetCommentLikes({
    required String bcotId,
    required String commentId,
  }) {
    return _firebaseFirestore
        .collection("bcots")
        .doc(bcotId)
        .collection("comments")
        .doc(commentId)
        .snapshots();
  }

  // ! Like / Unlike Comment
  static Future<void> LikeUnlikeComment({
    required String bcotId,
    required String userId,
    required String commentId,
  }) async {
    DocumentSnapshot snapshot = await _firebaseFirestore
        .collection("bcots")
        .doc(bcotId)
        .collection("comments")
        .doc(commentId)
        .get();

    final comment = CommentModel.fromSnapshot(snapshot);

    List likes = comment.likes;

    if (!likes.contains(userId)) {
      likes.add(userId);
    } else {
      likes.remove(userId);
    }

    try {
      await _firebaseFirestore
          .collection("bcots")
          .doc(bcotId)
          .collection("comments")
          .doc(commentId)
          .update({"likes": likes});
    } on FirebaseException catch (e) {
      print("ERROR LIKE $e");
    }
  }
}

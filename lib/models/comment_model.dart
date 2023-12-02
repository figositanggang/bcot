import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String userId;
  final String commentText;
  final Timestamp createdAt;
  final List likes;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.commentText,
    required this.createdAt,
    required this.likes,
  });

  Map<String, dynamic> toMap() => {
        "commentId": this.commentId,
        "userId": this.userId,
        "commentText": this.commentText,
        "createdAt": this.createdAt,
        "likes": this.likes,
      };

  factory CommentModel.fromSnapshot(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return CommentModel(
      commentId: snap["commentId"],
      userId: snap["userId"],
      commentText: snap["commentText"],
      createdAt: snap["createdAt"],
      likes: snap["likes"],
    );
  }
}

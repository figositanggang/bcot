import 'package:cloud_firestore/cloud_firestore.dart';

class BCotModel {
  final String bcotId;
  final String userId;
  final String bcot_text;
  final List likes;
  final Timestamp created_at;

  BCotModel({
    required this.bcotId,
    required this.userId,
    required this.bcot_text,
    required this.likes,
    required this.created_at,
  });

  Map<String, dynamic> toMap() => {
        "bcotId": this.bcotId,
        "userId": this.userId,
        "bcot_text": this.bcot_text,
        "likes": this.likes,
        "created_at": this.created_at,
      };

  factory BCotModel.fromSnapshot(DocumentSnapshot snapshot) {
    final snap = snapshot.data() as Map<String, dynamic>;

    return BCotModel(
      bcotId: snap["bcotId"],
      userId: snap["userId"],
      bcot_text: snap["bcot_text"],
      likes: snap["likes"],
      created_at: snap["created_at"],
    );
  }
}

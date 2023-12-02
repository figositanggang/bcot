import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String username;
  final String name;
  final String photoUrl;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.name,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        "userId": this.userId,
        "email": this.email,
        "username": this.username,
        "name": this.name,
        "photoUrl": this.photoUrl,
      };

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final snap = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      userId: snap["userId"],
      email: snap["email"],
      username: snap["username"],
      name: snap["name"],
      photoUrl: snap["photoUrl"],
    );
  }
}

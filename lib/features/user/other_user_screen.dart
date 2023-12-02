import 'package:bcot/features/comment/comments.dart';
import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/models/bcot_model.dart';
import 'package:bcot/models/user_model.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherUserScreen extends StatefulWidget {
  final String userId;

  const OtherUserScreen({super.key, required this.userId});

  @override
  State<OtherUserScreen> createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> getUser;
  late Query<Map<String, dynamic>> getMyBcots;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ! Get User and User's Bcots
  void getData() async {
    getUser = FirebaseFirestoreHelper.GetUser(widget.userId);
    getMyBcots = firebaseFirestore
        .collection("bcots")
        .where("userId", isEqualTo: widget.userId);
  }

  // ! Refresh Screen
  Future<void> refresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    getData();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser,
      builder: (context, snapshot) {
        // ? Getting user data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ? User not found
        if (!snapshot.hasData) {
          return Material(
            child: Center(
              child: Text("User ini tidak ada"),
            ),
          );
        }

        // ? Error
        if (snapshot.hasError) {
          return Material(
            child: Center(
              child: Text("Ada kesalahan..."),
            ),
          );
        }

        // ? SUCCESS
        final data = snapshot.data!;
        final user = UserModel.fromSnapshot(data);
        return Scaffold(
          appBar: AppBar(
            title: Text("@${user.username}"),
          ),
          body: RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: kToolbarHeight),

                  // @ Profile Picture & User Name
                  Column(
                    children: [
                      // @ Profile Picture
                      Ink(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(user.photoUrl),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.2),
                              blurRadius: 50,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {},
                        ),
                      ),
                      SizedBox(height: 30),

                      // @ User Name
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // @ User Bcots
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "Bacotan",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      FirestoreListView(
                        query: firebaseFirestore
                            .collection("bcots")
                            .where("userId", isEqualTo: widget.userId),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        loadingBuilder: (context) {
                          return Center(child: CircularProgressIndicator());
                        },
                        itemBuilder: (context, snapshot) {
                          final bcot = BCotModel.fromSnapshot(snapshot);

                          // @ BcotCard
                          return BCotCard(
                            enableRoute: false,
                            currentUserId:
                                context.watch<UserProvider>().user!.userId,
                            bcotModel: bcot,
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomRoute(Comments(bcot: bcot)),
                              );
                            },
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text("Ada Kesalahan..."),
                          );
                        },
                        emptyBuilder: (context) {
                          return SizedBox(
                            height: MediaQuery.sizeOf(context).height / 2,
                            child: Center(
                              child: Text("Bacotan user ini masih kosong"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

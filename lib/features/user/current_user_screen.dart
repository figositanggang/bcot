import 'package:bcot/features/comment/comments.dart';
import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/models/bcot_model.dart';
import 'package:bcot/models/user_model.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:bcot/utils/custom_theme.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  final String userId;

  const UserScreen({super.key, required this.userId});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> getUser;
  late Query<Map<String, dynamic>> getMyBcots;
  late UserProvider userProvider;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

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
    getUser
      ..then((value) {
        userProvider.user = UserModel.fromSnapshot(value);
      });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("@${userProvider.user!.username}"),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // @ Data User
              Column(
                children: [
                  SizedBox(height: kToolbarHeight),

                  Ink(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            context.watch<UserProvider>().user!.photoUrl),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(.2),
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
                    userProvider.user!.name,
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
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Bacotan: ",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),

                  // @ List Bcots
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
                        currentUserId:
                            context.watch<UserProvider>().user!.userId,
                        bcotModel: bcot,
                        enableRoute: false,
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
                          child: Text("Bacotanmu masih kosong"),
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
  }
}

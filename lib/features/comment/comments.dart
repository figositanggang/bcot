import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/models/bcot_model.dart';
import 'package:bcot/models/comment_model.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Comments extends StatefulWidget {
  final BCotModel bcot;

  const Comments({
    super.key,
    required this.bcot,
  });

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  late TextEditingController commentController;
  late Stream<QuerySnapshot<Map<String, dynamic>>> streamAllComments;
  late UserProvider userProvider;

  final currentUser = FirebaseAuth.instance.currentUser!;
  final formKey = GlobalKey<FormState>();

  // ! INIT STATE
  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    commentController = TextEditingController();

    streamAllComments =
        FirebaseFirestoreHelper.StreamComments(widget.bcot.bcotId);
  }

  // ! DISPOSE
  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  // ! POST COMMENT
  Future<void> addComment(String commentText) async {
    try {
      await FirebaseFirestoreHelper.AddComment(
        bcotId: widget.bcot.bcotId,
        userId: currentUser.uid,
        commentText: commentText,
      );

      commentController.text = "";
    } catch (e) {
      print("GAGAL KOMEN");
    }
  }

  void refresh() {
    getData();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant Comments oldWidget) {
    super.didUpdateWidget(oldWidget);

    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Komen"),
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: 30 + kBottomNavigationBarHeight),
        child: RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // @ The Bcot
                BCotCard(
                  currentUserId: context.watch<UserProvider>().user!.userId,
                  bcotModel: widget.bcot,
                  bgColor: Theme.of(context).primaryColor.withOpacity(.2),
                  deleteAble: false,
                ),
                SizedBox(height: 20),

                Text("Komen"),
                SizedBox(height: 20),

                StreamBuilder(
                  stream: streamAllComments,
                  builder: (context, snapshot) {
                    // ? LOADING COMMENTS
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // ? NO COMMENTS
                    if (snapshot.data!.docs.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: Center(
                          child: Text("Belum ada komen"),
                        ),
                      );
                    }

                    // ? SUCCESS
                    if (snapshot.hasData && snapshot.data!.docs.length != 0) {
                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          CommentModel comment =
                              CommentModel.fromSnapshot(docs[index]);

                          // @ Comment Card
                          return CommentCard(
                            comment: comment,
                            bcotId: widget.bcot.bcotId,
                          );
                          // return Text("AWAWAW");
                        },
                      );
                    }

                    // ? ERROR
                    return Center(
                      child: Text("Error"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(left: 20),
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // @ TextField
              Expanded(
                child: CustomTextField(
                  controller: commentController,
                  autovalidateMode: AutovalidateMode.disabled,
                  hintText: "Tambahkan komen...",
                  border: OutlineInputBorder(),
                  keyboardType: TextInputType.text,
                ),
              ),

              // @ Add Button
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    addComment(commentController.text.trim());
                  }
                },
                child: Text("Post"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

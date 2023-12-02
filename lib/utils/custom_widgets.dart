import 'package:bcot/features/user/other_user_screen.dart';
import 'package:bcot/utils/custom_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/models/bcot_model.dart';
import 'package:bcot/models/comment_model.dart';
import 'package:bcot/models/user_model.dart';

// @ BCot Card
class BCotCard extends StatefulWidget {
  final BCotModel bcotModel;
  final void Function()? onTap;
  final bool deleteAble;
  final Color? bgColor;
  final String currentUserId;
  final bool enableRoute;

  BCotCard({
    Key? key,
    required this.bcotModel,
    required this.currentUserId,
    this.onTap = null,
    this.bgColor,
    this.deleteAble = true,
    this.enableRoute = true,
  }) : super(key: key);

  @override
  State<BCotCard> createState() => _BCotCardState();
}

class _BCotCardState extends State<BCotCard> {
  // ! Remove Bcot
  void removeBcot() async {
    await showDialog(
      context: context,
      builder: (context) => MyAlertDialog(
        content: "Yakin hapus bcot?",
        onYes: () async {
          await FirebaseFirestoreHelper.RemoveBcot(widget.bcotModel.bcotId);

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            MySnackBar("Berhasil hapus bcot"),
          );
        },
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // @ Navigate To Comment List
      onTap: widget.onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              color: widget.bgColor ?? null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // @ user profile picture
                FutureBuilder(
                  future:
                      FirebaseFirestoreHelper.GetUser(widget.bcotModel.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar();
                    }

                    UserModel user = UserModel.fromSnapshot(snapshot.data!);
                    return Ink(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(user.photoUrl),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: widget.enableRoute
                            ? () {
                                Navigator.push(
                                  context,
                                  CustomRoute(
                                      OtherUserScreen(userId: user.userId)),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // @ username
                          FutureBuilder(
                            future: FirebaseFirestoreHelper.GetUser(
                                widget.bcotModel.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("");
                              }

                              final UserModel user =
                                  UserModel.fromSnapshot(snapshot.data!);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${user.name}",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.25,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "@${user.username}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.75),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          // @ Date Post
                          Text(generateDate(
                            now: DateTime.now(),
                            createdAt: widget.bcotModel.created_at.toDate(),
                          )),
                        ],
                      ),
                      SizedBox(height: 5),

                      // @ BCot
                      Text(
                        widget.bcotModel.bcot_text,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 20),

                      // @ Like and Comment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // @ Likes
                              StreamBuilder(
                                stream: FirebaseFirestoreHelper.StreamBcotLikes(
                                    widget.bcotModel.bcotId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final likes =
                                        BCotModel.fromSnapshot(snapshot.data!)
                                            .likes;

                                    return Text(
                                      "${likes.length} likes",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.75),
                                      ),
                                    );
                                  }

                                  return Text("0 likes");
                                },
                              ),
                              SizedBox(width: 10),

                              // @ Comments
                              StreamBuilder(
                                stream: FirebaseFirestoreHelper.StreamComments(
                                    widget.bcotModel.bcotId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final comments = snapshot.data!.docs;

                                    return Text(
                                      "${comments.length} comments",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.75),
                                      ),
                                    );
                                  }

                                  return Text("0 comments");
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // @ Like Button
                              IconButton(
                                padding: EdgeInsets.all(15),
                                onPressed: () async {
                                  await FirebaseFirestoreHelper.LikeUnlikeBcot(
                                    bcotId: widget.bcotModel.bcotId,
                                    userId: widget.currentUserId,
                                  );
                                },
                                icon: StreamBuilder(
                                  stream:
                                      FirebaseFirestoreHelper.StreamBcotLikes(
                                          widget.bcotModel.bcotId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final bcot = BCotModel.fromSnapshot(
                                          snapshot.data!);

                                      bool isLiked = bcot.likes
                                          .contains(widget.currentUserId);

                                      return FaIcon(
                                        isLiked
                                            ? FontAwesomeIcons.solidHeart
                                            : FontAwesomeIcons.heart,
                                        size: 20,
                                        color: isLiked
                                            ? Theme.of(context).primaryColor
                                            : Colors.white.withOpacity(.5),
                                      );
                                    }

                                    return FaIcon(
                                      FontAwesomeIcons.heart,
                                      size: 20,
                                      color: Colors.white.withOpacity(.5),
                                    );
                                  },
                                ),
                              ),

                              // @ More Button
                              widget.bcotModel.userId == widget.currentUserId &&
                                      widget.deleteAble
                                  ? IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          isDismissible: true,
                                          showDragHandle: true,
                                          barrierLabel: "aw",
                                          barrierColor:
                                              Colors.black.withOpacity(.5),
                                          useSafeArea: true,
                                          context: context,
                                          builder: (context) => MyBottomSheet(
                                            // @ List BottomSheetItem
                                            items: [
                                              BottomSheetItem(
                                                text: "Hapus Bcot",
                                                isDanger: true,
                                                onPressed: removeBcot,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: FaIcon(FontAwesomeIcons.ellipsis),
                                      padding: EdgeInsets.zero,
                                    )
                                  : SizedBox()
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            color: Colors.white.withOpacity(.1),
          ),
        ],
      ),
    );
  }
}

// @ Custom Page Transition
Route CustomRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionDuration: Duration(milliseconds: 250),
    reverseTransitionDuration: Duration(milliseconds: 100),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}

// @ Custom TextFormField
Widget CustomTextField({
  required TextEditingController controller,
  void Function(String value)? onChanged,
  required String hintText,
  InputBorder? border,
  String? Function(String? value)? validator,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  Widget? suffixIcon,
  bool obscureText = false,
  Iterable<String>? autofillHints,
  AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextFormField(
    controller: controller,
    maxLines: obscureText ? 1 : null,
    onChanged: onChanged,
    autovalidateMode: autovalidateMode,
    keyboardType: keyboardType ?? TextInputType.name,
    textInputAction: textInputAction ?? TextInputAction.next,
    obscureText: obscureText,
    autofillHints: autofillHints,
    inputFormatters: inputFormatters,
    validator: validator ??
        (value) {
          if (value!.isEmpty) {
            return "Masih kosong...";
          }

          return null;
        },
    onTapOutside: (event) {
      FocusManager.instance.primaryFocus!.unfocus();
    },
    decoration: InputDecoration(
      contentPadding: EdgeInsets.all(20),
      hintText: hintText,
      border: border,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.25)),
      ),
      suffixIcon: suffixIcon,
    ),
  );
}

// @ Custom Primary Button
Widget PrimaryButton(
  BuildContext context, {
  required void Function()? onPressed,
  required Widget? child,
  BorderRadius? borderRadius,
  EdgeInsetsGeometry? padding,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: child,
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(5),
      ),
      padding: padding,
    ),
  );
}

// @ Comment Card UI
class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final String bcotId;

  CommentCard({
    super.key,
    required this.comment,
    required this.bcotId,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  late Future<DocumentSnapshot<Map<String, dynamic>>> getUser;

  String date = "";

  @override
  void initState() {
    super.initState();

    getUser = FirebaseFirestoreHelper.GetUser(widget.comment.userId);
  }

  void removeComment(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => MyAlertDialog(
        content: "Yakin hapus bcot?",
        onYes: () async {
          await FirebaseFirestoreHelper.RemoveComment(
            bcotId: widget.bcotId,
            commentId: widget.comment.commentId,
          );

          Navigator.pop(context);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            MySnackBar("Berhasil hapus komen"),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // @ User Profile Picture
              FutureBuilder(
                future: getUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                    );
                  }

                  UserModel user = UserModel.fromSnapshot(snapshot.data!);
                  return Ink(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(user.photoUrl),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomRoute(OtherUserScreen(userId: user.userId)),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // @ username & date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // @ username
                        FutureBuilder(
                          future: getUser,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("");
                            }

                            final UserModel user =
                                UserModel.fromSnapshot(snapshot.data!);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${user.name}",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.25,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "@${user.username}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.75),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // @ date comment created
                        Text(
                          generateDate(
                              now: DateTime.now(),
                              createdAt: widget.comment.createdAt.toDate()),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    // @ Comment
                    Text(
                      widget.comment.commentText,
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),

                    //   Row(
                    //     mainAxisSize: MainAxisSize.max,
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       // @ Stream Likes
                    //       StreamBuilder(
                    //         stream: _firebaseFirestore
                    //             .collection("bcots")
                    //             .doc(widget.bcotId)
                    //             .collection("comments")
                    //             .doc(widget.comment.commentId)
                    //             .snapshots(),
                    //         builder: (context, snapshot) {
                    //           if (snapshot.hasData && snapshot.data!.exists) {
                    //             final likes =
                    //                 CommentModel.fromSnapshot(snapshot.data!)
                    //                     .likes;

                    //             return Text(
                    //               "${likes.length} likes",
                    //               style: TextStyle(
                    //                 color: Colors.white.withOpacity(.75),
                    //               ),
                    //             );
                    //           }

                    //           return Text("0 likes");
                    //         },
                    //       ),

                    //       SizedBox(width: 5),

                    //       Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           // @ Like Button
                    //           IconButton(
                    //             padding: EdgeInsets.all(15),
                    //             onPressed: () {
                    //               FirebaseFirestoreHelper.LikeUnlikeComment(
                    //                 bcotId: widget.bcotId,
                    //                 userId: currentUser.uid,
                    //                 commentId: widget.comment.commentId,
                    //               );
                    //             },
                    //             icon: StreamBuilder(
                    //               stream: _firebaseFirestore
                    //                   .collection("bcots")
                    //                   .doc(widget.bcotId)
                    //                   .collection("comments")
                    //                   .doc(widget.comment.commentId)
                    //                   .snapshots(),
                    //               builder: (context, snapshot) {
                    //                 if (snapshot.hasData &&
                    //                     snapshot.data!.exists) {
                    //                   final comment = CommentModel.fromSnapshot(
                    //                       snapshot.data!);

                    //                   bool isLiked =
                    //                       comment.likes.contains(currentUser.uid);

                    //                   return FaIcon(
                    //                     isLiked
                    //                         ? FontAwesomeIcons.solidHeart
                    //                         : FontAwesomeIcons.heart,
                    //                     size: 20,
                    //                     color: isLiked
                    //                         ? Theme.of(context).primaryColor
                    //                         : Colors.white.withOpacity(.5),
                    //                   );
                    //                 }

                    //                 return FaIcon(
                    //                   FontAwesomeIcons.heart,
                    //                   size: 20,
                    //                   color: Colors.white.withOpacity(.5),
                    //                 );
                    //               },
                    //             ),
                    //           ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // @ More Button
                        widget.comment.userId == currentUser.uid
                            ? IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    isDismissible: true,
                                    showDragHandle: true,
                                    barrierColor: Colors.black.withOpacity(.5),
                                    useSafeArea: true,
                                    context: context,
                                    builder: (context) => MyBottomSheet(
                                      // @ List BottomSheetItem
                                      items: [
                                        BottomSheetItem(
                                          text: "Hapus Komen",
                                          isDanger: true,
                                          onPressed: () {
                                            removeComment(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: FaIcon(FontAwesomeIcons.ellipsis),
                                padding: EdgeInsets.zero,
                              )
                            : SizedBox()
                      ],
                    )
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 0,
          color: Colors.white.withOpacity(.1),
        ),
      ],
    );
  }
}

// @ Custom SnackBar
SnackBar MySnackBar(String content) {
  return SnackBar(
    content: Text(content),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(
      vertical: 20,
      horizontal: 30,
    ),
    showCloseIcon: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

// @ Custom Alert Dialog
class MyAlertDialog extends StatelessWidget {
  final String content;
  final void Function() onYes;

  const MyAlertDialog({
    super.key,
    required this.content,
    required this.onYes,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.only(top: 20, bottom: 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // @ Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                content,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Divider(
                height: 0,
                color: Colors.white.withOpacity(.1),
              ),
            ],
          ),
          SizedBox(height: 20),

          // @ On Yes
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onYes,
              child: Text(
                "Ya",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),

          // @ On Cancel
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Tidak",
                style: TextStyle(color: Colors.white.withOpacity(.75)),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// @ Custom Modal Bottom Sheet
class MyBottomSheet extends StatelessWidget {
  final List<BottomSheetItem> items;

  MyBottomSheet({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      constraints: BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          items.length,
          (index) => items[index],
        ),
      ),
    );
  }
}

// @ Bottom Sheet Item
class BottomSheetItem extends StatelessWidget {
  final String text;
  final bool isDanger;
  final void Function() onPressed;

  BottomSheetItem({
    super.key,
    required this.text,
    this.isDanger = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: isDanger ? Colors.red : Theme.of(context).primaryColor,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}

// @ User Profile Picture
// ignore: must_be_immutable
class UserProfilePicture extends StatelessWidget {
  final double width;
  final String imageUrl;
  void Function()? onTap = () {};

  UserProfilePicture({
    super.key,
    required this.width,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 10,
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: InkWell(
        onTap: onTap,
      ),
    );
  }
}

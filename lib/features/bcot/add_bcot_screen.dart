import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/features/bcot/home_screen.dart';
import 'package:bcot/models/user_model.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:flutter/material.dart';

class AddBCotScreen extends StatefulWidget {
  final String currentUserId;
  final String username;
  final String photoUrl;

  const AddBCotScreen({
    super.key,
    required this.currentUserId,
    required this.username,
    required this.photoUrl,
  });

  @override
  State<AddBCotScreen> createState() => _AddBCotScreenState();
}

class _AddBCotScreenState extends State<AddBCotScreen> {
  TextEditingController bcotController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Future getUser;

  @override
  void initState() {
    super.initState();

    getUser = FirebaseFirestoreHelper.GetUser(widget.currentUserId);
  }

  @override
  void dispose() {
    bcotController.dispose();

    super.dispose();
  }

  Future<void> addBcot() async {
    showDialog(
      context: context,
      builder: (context) => Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    await Future.delayed(Duration(seconds: 1));
    await FirebaseFirestoreHelper.AddBcot(
      bcot_text: bcotController.text.trim(),
      userId: widget.currentUserId,
    );

    Navigator.pushAndRemoveUntil(
        context, CustomRoute(HomeScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Material();
        }

        final UserModel user = UserModel.fromSnapshot(snapshot.data!);
        return Scaffold(
          appBar: AppBar(
            title: Text("@${user.username} NgeBcot"),
            actions: [
              // @ Post Button
              PrimaryButton(
                context,
                onPressed: addBcot,
                child: Text("Post"),
                borderRadius: BorderRadius.circular(20),
              ),

              SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Container(
                padding: EdgeInsets.only(right: 15),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(widget.photoUrl),
                      ),
                      title: CustomTextField(
                        controller: bcotController,
                        hintText: "Bacotanmu...",
                        textInputAction: TextInputAction.go,
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      trailing: Text(bcotController.text.length.toString()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

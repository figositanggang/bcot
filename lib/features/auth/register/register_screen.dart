import 'package:bcot/features/auth/register/pick_avatar.dart';
import 'package:bcot/features/auth/register/register_provider.dart';
import 'package:bcot/firebase/firebase_auth_helper.dart';
import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/main.dart';
import 'package:bcot/models/user_model.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SignUnScreen extends StatefulWidget {
  const SignUnScreen({super.key});

  @override
  State<SignUnScreen> createState() => _SignUnScreenState();
}

class _SignUnScreenState extends State<SignUnScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData() {
    streamUsers = FirebaseFirestoreHelper.streamUsers();
  }

  @override
  Widget build(BuildContext context) {
    final registerProv = Provider.of<RegisterProvider>(context);

    return StreamBuilder(
        stream: streamUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Material();
          }

          final docs = snapshot.data!.docs;
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height - kToolbarHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // @ Login Form
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Text(
                                  "Daftar",
                                  style: TextStyle(fontSize: 30),
                                ),
                                SizedBox(height: 15),

                                // @ email
                                CustomTextField(
                                  controller: registerProv.email,
                                  hintText: "email",
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: [AutofillHints.email],
                                  validator: (value) {
                                    RegExp email = RegExp(
                                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

                                    if (!email.hasMatch(value!)) {
                                      return "Email tidak valid...";
                                    }
                                    if (value.isEmpty) {
                                      return "Masih kosong...";
                                    }

                                    return null;
                                  },
                                ),
                                SizedBox(height: 5),

                                // @ username
                                CustomTextField(
                                  controller: registerProv.username,
                                  hintText: "username",
                                ),
                                SizedBox(height: 5),

                                // @ name
                                CustomTextField(
                                  controller: registerProv.name,
                                  hintText: "name",
                                ),
                                SizedBox(height: 5),

                                // @ password
                                CustomTextField(
                                  controller: registerProv.password,
                                  hintText: "password",
                                  textInputAction: TextInputAction.go,
                                  obscureText: obscureText,
                                  autofillHints: [AutofillHints.password],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Masih kosong...";
                                    }
                                    if (value.length < 6) {
                                      return "Panjang password harus lebih dari 6 karakter";
                                    }

                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    icon: Icon(
                                      obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: !obscureText
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),

                                // @ Pick Avatar Button
                                PrimaryButton(
                                  context,
                                  onPressed: () async {
                                    bool _isAvailable = true;
                                    if (formKey.currentState!.validate()) {
                                      for (var element in docs) {
                                        UserModel user =
                                            UserModel.fromSnapshot(element);

                                        if (registerProv.username.text.trim() ==
                                            user.username) {
                                          _isAvailable = false;
                                          break;
                                        }
                                      }

                                      if (_isAvailable) {
                                        Navigator.push(
                                          context,
                                          CustomRoute(PickAvatar()),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(MySnackBar(
                                                "Username telah digunakan"));
                                      }
                                    }
                                  },
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Pilih Avatar"),
                                        SizedBox(width: 10),
                                        FaIcon(
                                          FontAwesomeIcons.angleRight,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),

                          // @ Sudah punya akun
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Sudah punya akun?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Masuk"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

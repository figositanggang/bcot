import 'package:bcot/utils/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  Future<void> sendPasswordResetEmail() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: emailController.text.trim())
          .get();

      await Future.delayed(Duration(seconds: 1));

      if (snapshot.docs.isNotEmpty) {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Link reset password telah dikirim")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tidak ada user dengan email tersebut")));
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lupa Password"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: emailController,
                  hintText: "Masukkan email untuk ubah password...",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    RegExp email = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

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
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    context,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        sendPasswordResetEmail();
                      }
                    },
                    child: Text("Kirim link"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

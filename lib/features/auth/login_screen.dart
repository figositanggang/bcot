import 'package:bcot/features/auth/reset_password_screen.dart';
import 'package:bcot/features/auth/register/register_screen.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:bcot/firebase/firebase_auth_helper.dart';
import 'package:bcot/main.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late UserProvider userProvider;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ! Sign In
  void signIn() async {
    showDialog(
      context: context,
      builder: (context) => Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    String res = await FirebaseAuthHelper.signIn(
      email: emailController.text,
      password: passwordController.text,
      userProvider: userProvider,
    );

    if (res == "success") {
      Navigator.pushAndRemoveUntil(
          context, CustomRoute(AuthState()), (route) => false);
    }

    if (res == 'INVALID_LOGIN_CREDENTIALS') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ada yang salah")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight),
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
                            "Masuk",
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(height: 15),

                          // @ email
                          CustomTextField(
                            controller: emailController,
                            hintText: "email",
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: [AutofillHints.email],
                            validator: (value) {
                              RegExp email =
                                  RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

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

                          // @ password
                          CustomTextField(
                            controller: passwordController,
                            hintText: "password",
                            textInputAction: TextInputAction.go,
                            obscureText: obscureText,
                            autofillHints: [AutofillHints.password],
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r" "))
                            ],
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

                          // @ Login Button
                          PrimaryButton(
                            context,
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                signIn();
                              }
                            },
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text("Masuk"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),

                    // @ Lupa Password
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context, CustomRoute(ResetPasswordScreen()));
                        },
                        child: Text("Lupa Password"),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(5)),
                      ),
                    ),

                    // @ Belum punya akun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Belum punya akun?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context, CustomRoute(SignUnScreen()));
                          },
                          child: Text("Buat Akun"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                          ),
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
  }
}

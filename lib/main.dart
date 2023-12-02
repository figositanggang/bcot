import 'package:bcot/features/auth/login_screen.dart';
import 'package:bcot/features/auth/register/register_provider.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:bcot/firebase_options.dart';
import 'package:bcot/features/bcot/home_screen.dart';
import 'package:bcot/utils/custom_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => RegisterProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BCot',
      theme: themeData,
      home: AuthState(),
    );
  }
}

class AuthState extends StatelessWidget {
  AuthState({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser != null) {
      return HomeScreen();
    }

    return SignInScreen();
  }
}

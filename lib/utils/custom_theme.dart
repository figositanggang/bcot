import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData themeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromARGB(255, 19, 27, 34),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
    primaryColor: Color.fromARGB(255, 1, 151, 226),

    // appBarTheme
    appBarTheme: AppBarTheme(backgroundColor: Color.fromARGB(255, 28, 40, 51)),

    // textTheme
    textTheme: GoogleFonts.latoTextTheme().apply(bodyColor: Colors.white));

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: ancestor);
  }

  @override
  SpringDescription get spring => SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 100,
      );
}

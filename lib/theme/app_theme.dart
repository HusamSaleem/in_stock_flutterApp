import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey[700],
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
          titleSpacing: 1.0,
          color: Colors.grey[850],
          iconTheme: const IconThemeData(color: Colors.white)),
      cardTheme: const CardTheme(color: Colors.black45),
      iconTheme: const IconThemeData(color: Colors.white54),
      textTheme: const TextTheme(
        subtitle1:
            TextStyle(color: Colors.white, fontSize: 16.0, letterSpacing: 1.0),
        subtitle2: TextStyle(fontSize: 10.0, letterSpacing: 1.0),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ));
}

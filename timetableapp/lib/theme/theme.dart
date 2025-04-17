import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(color: Colors.blue, elevation: 0),
    textTheme: TextTheme(titleLarge: TextStyle(color: Color(0xFF000000))),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(color: Colors.grey[900], elevation: 0),
    textTheme: TextTheme(titleLarge: TextStyle(color: Color(0xFFFFFFFF))),
  );
}

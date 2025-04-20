import 'package:flutter/material.dart';
import 'package:smodderz/theme/theme.dart';

class AppTheme {
  static ThemeData theme = ThemeData.dark().copyWith(
    // scaffoldBackgroundColor: Palette.backgroundColor,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Palette.backgroundColor,
    //   elevation: 0,
    // ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Palette.blueColor),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16), // Set the default text size here
    ),
  );
}

import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static const int LIGHT = 0;
  static const int DARK = 1;
}

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.LIGHT: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light, secondaryHeaderColor: Colors.grey[300], primaryColorDark: Colors.blue),
    AppThemes.DARK: ThemeData(primarySwatch: Colors.grey, elevatedButtonTheme: darkButtonTheme, brightness: Brightness.dark, primaryColorBrightness: Brightness.dark, primaryColorDark: Colors.blue),
  },
  fallbackTheme: ThemeData.light(),
);

final darkButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[900]!),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
  ),
);
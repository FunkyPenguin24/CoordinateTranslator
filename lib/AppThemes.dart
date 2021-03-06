import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static const int LIGHT = 0;
  static const int DARK = 1;
}

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.LIGHT: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
    AppThemes.DARK: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
  },
  fallbackTheme: ThemeData.light(),
);
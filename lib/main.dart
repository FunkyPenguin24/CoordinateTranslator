import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'AppThemes.dart';
import 'ConverterScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      themeCollection: themeCollection,
      defaultThemeId: AppThemes.LIGHT,
      builder: (context, theme) {
        return MaterialApp(
          title: 'Coordinate translator',
          theme: theme,
          home: MyHomePage(title: 'Coordinate Translator'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Widget build(BuildContext context) {
    return Scaffold(
      body: ConverterScreen(),
    );
  }

}

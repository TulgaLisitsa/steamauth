import 'package:flutter/material.dart';

import 'colors.dart';
import 'screens/home_screen.dart';
import 'screens/new_account_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(Application());

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vapor',
      theme: _buildTheme(),
      home: HomeScreen(title: 'Dashboard'),
      routes: <String, WidgetBuilder>{
        '/new': (BuildContext context) =>
            new NewAccountScreen(title: 'Enter account details'),
        '/settings': (BuildContext context) =>
            new SettingsScreen(title: 'Settings')
      },
    );
  }
}

ThemeData _buildTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: kPrimary,
    accentColorBrightness: Brightness.dark,
    primaryColor: kPrimary,
    primaryColorDark: kPrimaryDark,
    primaryColorLight: kPrimaryLight,
    scaffoldBackgroundColor: kBackgroundGrey,
    textSelectionHandleColor: kPrimaryDark,
    textSelectionColor: kPrimaryHighlight,
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
    primaryIconTheme: base.iconTheme.copyWith(color: Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      isDense: false,
      border: UnderlineInputBorder(),
    ),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
          headline: base.headline.copyWith(
            fontWeight: FontWeight.w500,
          ),
          title:
              base.title.copyWith(fontSize: 19.0, fontWeight: FontWeight.w600),
          caption: base.caption.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 14.0,
              color: kTextSecondaryColor),
          display1: base.display1.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: 0.5, color: kPrimary))
      .apply(fontFamily: 'Roboto');
}

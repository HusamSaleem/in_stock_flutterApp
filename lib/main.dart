import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_stock_tracker/models/user.dart';
import 'package:in_stock_tracker/pages/main_screen.dart';
import 'package:in_stock_tracker/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadUserInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('userInfo');

  //print(userJson);
  if (userJson != null) {
    user = User.fromJson(json.decode(userJson));
  }
}

Future<void> purgeData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadUserInfo();
  runApp(MaterialApp(
    initialRoute: '/home',
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
    routes: {'/home': (context) => const MainView()},
  ));
}

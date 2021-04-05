import 'dart:io';

import 'package:Riverto/signIn.dart';
import 'package:flutter/material.dart';
import 'package:Riverto/style/appColors.dart';
import 'package:Riverto/ui/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool log = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoggedIn();
    });
  }

  void isLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      // pref.setBool("logIn", false);
      log = pref.getBool("logIn");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Riverto",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "DMSans",
        accentColor: accent,
        primaryColor: accent,
        canvasColor: Colors.transparent,
      ),
      home: log != null
          ? log
              ? Riverto()
              : SignIn()
          : SignIn(),
    );
  }
}

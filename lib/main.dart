import 'package:Riverto/signIn.dart';
import 'package:flutter/material.dart';
import 'package:Riverto/style/appColors.dart';
import 'package:Riverto/screen/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool log = false;

  @override
  void initState() {
    super.initState();
    Const.dbSetup();
    setState(() {
      isLoggedIn();
    });
  }

  void isLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      log = pref.getBool("logIn");
    });
    Const.change();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Riverto",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Less",
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

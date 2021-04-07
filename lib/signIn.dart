import 'package:Riverto/style/appColors.dart';
import 'package:Riverto/screen/homePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'Models/formConstructor.dart';
import 'Models/formController.dart';
import 'const.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    submit(String name, String email) async {
      FormConstructor formConstructor =
          FormConstructor(name: name, feedback: "vs", email: email);

      FormController formController = FormController((dynamic response) {
        if (response == 1) {
        } else {}
      });

      formController.submitForm(formConstructor);
    }

    return Scaffold(
      body: Container(
        // color: Color(0xff263238),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff263238),
              Color(0xff263238),
              Color(0xff384850),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: Text(
                  "Hola.",
                  style: TextStyle(
                    // fontFamily: "SFPro",
                    color: Theme.of(context).primaryColor,
                    fontSize: 90,
                  ),
                ),
              ),
              Form(
                key: key,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) {
                        return val.length > 1
                            ? null
                            : "Please enter your name !";
                      },
                      controller: name,
                      style: TextStyle(
                        fontSize: 16,
                        color: accent,
                      ),
                      cursorColor: Colors.green[50],
                      decoration: InputDecoration(
                        fillColor: Color(0xff263238),
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                          borderSide: BorderSide(
                            color: Color(0xff263238),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                          borderSide: BorderSide(color: accent),
                        ),
                        border: InputBorder.none,
                        hintText: "What's your name ?",
                        hintStyle: TextStyle(
                          color: accent,
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 18,
                          right: 20,
                          top: 14,
                          bottom: 14,
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) {
                        return EmailValidator.validate(val)
                            ? null
                            : "Please enter a valid email ID!";
                      },
                      controller: email,
                      style: TextStyle(
                        fontSize: 16,
                        color: accent,
                      ),
                      cursorColor: Colors.green[50],
                      decoration: InputDecoration(
                        fillColor: Color(0xff263238),
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                          borderSide: BorderSide(
                            color: Color(0xff263238),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                          borderSide: BorderSide(color: accent),
                        ),
                        border: InputBorder.none,
                        hintText: "Enter your email ID!",
                        hintStyle: TextStyle(
                          color: accent,
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 18,
                          right: 20,
                          top: 14,
                          bottom: 14,
                        ),
                      ),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile ||
                      connectivityResult == ConnectivityResult.wifi) {
                    if (key.currentState.validate()) {
                      Const.setValues("name", name.text);
                      Const.setValues("email", email.text);
                      Const.logIn();
                      submit(name.text, email.text);
                      Navigator.pushReplacement(context,
                          CupertinoPageRoute(builder: (context) => Riverto()));
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: "You are not connected to internet",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Color(0xff61e88a),
                      fontSize: 14.0,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff4db6ac),
                          Color(0xff61e88a),
                        ],
                      )),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Get me in",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              )
            ],
          ),
        ),
      ),
    );
  }
}

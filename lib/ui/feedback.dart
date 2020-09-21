import 'package:Riverto/Models/formConstructor.dart';
import 'package:Riverto/Models/formController.dart';
import 'package:Riverto/style/appColors.dart';
import 'package:Riverto/ui/homePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../const.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  TextEditingController feedback = new TextEditingController();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    submit(String feedback) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String name = pref.getString("name");
      String email = pref.getString("email");
      FormConstructor formConstructor =
          FormConstructor(name: name, feedback: feedback, email: email);

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
              Color(0xff384850),
              Color(0xff263238),
              Color(0xff263238),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 8),
              Text(
                "Feedback.",
                style: TextStyle(
                  // fontFamily: "SFPro",
                  color: Theme.of(context).primaryColor,
                  fontSize: 60,
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: key,
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      child: TextFormField(
                        validator: (val) {
                          return val.length > 1 ? null : "Field can't be empty";
                        },
                        controller: feedback,
                        style: TextStyle(
                          fontSize: 16,
                          color: accent,
                        ),
                        maxLines: 9999999,
                        cursorColor: Colors.green[50],
                        decoration: InputDecoration(
                          fillColor: Color(0xff263238),
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide: BorderSide(
                              color: Color(0xff263238),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide: BorderSide(color: accent),
                          ),
                          border: InputBorder.none,
                          hintText: "Send us your experience!",
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
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Expanded(child: Container()),
              GestureDetector(
                onTap: () async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile ||
                      connectivityResult == ConnectivityResult.wifi) {
                    if (key.currentState.validate()) {
                      Const.logIn();
                      submit(feedback.text);
                      Fluttertoast.showToast(
                        msg: "Thanks for your feedback!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Color(0xff61e88a),
                        fontSize: 14.0,
                      );

                      Navigator.pop(context);
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
                    "Submit",
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

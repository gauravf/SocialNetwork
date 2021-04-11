import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //for snackbar
  final _formKey = GlobalKey<FormState>(); //for form
  String username;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) { //if form is valid then save
      form.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
      Navigator.pop(context, username);
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: "Set Up Your Profile", removeBackButton: true),
      body: ListView(
        children: [
          Container(
            //height: 40.0,
            width: 350.0,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a Username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        validator: (val) { //validations to a form
                          if (val.trim().length < 3 || val.isEmpty) { //if user-name is too short
                            return "UserName too Short";
                          } else if (val.trim().length > 12) { //if username is too long
                            return "UserName too Long";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          height: 2.0,
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

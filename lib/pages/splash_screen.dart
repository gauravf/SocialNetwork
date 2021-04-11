import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'home.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: Home(),
      loadingText: Text("Loading.....",style: TextStyle(fontFamily: "Signatra",fontSize: 40),),
      photoSize: 100.0,
      gradientBackground: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.teal, Colors.deepPurple,Colors.red],
      ),
      backgroundColor: Colors.blue,
      image: Image.asset("assets/images/logo 2.png"),
    );
  }
}

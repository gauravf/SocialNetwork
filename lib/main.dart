import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application/pages/splash_screen.dart';
import 'package:flutter_application/widgets/theme_change.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(
        ThemeData.light(),
      ),
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      title: 'Social Network',
      debugShowCheckedModeBanner: false,
      home: Splash(),
      theme: theme.getTheme(),
    );
  }
}

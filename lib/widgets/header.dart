import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String titleText,
    removeBackButton = false,
    }) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    //if we want to remove back button in appbar
    title: Text(
      isAppTitle ? "Social Network" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 35.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
   // backgroundColor: Theme.of(context).accentColor,
    // actions: [
    //   settings
    //       ? Scaffold(
    //     drawer: Drawer(),
    //   )
    //       : Text(""),
    // ],
  );
}

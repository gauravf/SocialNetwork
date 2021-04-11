import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/pages/activity_feed.dart';
import 'package:flutter_application/pages/create_account.dart';
import 'package:flutter_application/pages/profile.dart';
import 'package:flutter_application/pages/search.dart';
import 'package:flutter_application/pages/timeline.dart';
import 'package:flutter_application/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(); //reference of google sign in
final Reference storageRef = FirebaseStorage.instance
    .ref(); //to get instance of firebase storage for uploading pic
final usersRef = FirebaseFirestore.instance
    .collection('users'); //referencing to users collection
final postsRef = FirebaseFirestore.instance
    .collection('posts'); //referencing to post collection
final commentsRef = FirebaseFirestore.instance
    .collection('comments'); //referencing to comments collection
final activityFeedRef = FirebaseFirestore.instance
    .collection('feed'); //referencing to fed collection
final followersRef = FirebaseFirestore.instance
    .collection('followers'); //referencing to followers collection
final followingRef = FirebaseFirestore.instance
    .collection('following'); //referencing to following collection
final timelineRef = FirebaseFirestore.instance
    .collection('timeline'); //referencing to following collection
final DateTime timestamp = DateTime.now(); //to get current time

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth =
      false; //when it is true auth screen is displayed and when false un_auth screen is displayed
  int pageIndex = 0;
  PageController pageController; //enables to switch between the pages

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(); //initialize page controller

    //detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      //if any error occurs while signing in...
      print('Error signing in: $err');
    });

    //re-authenticate user when app is opened....no need to sign in again
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore(); //to create user in fire store
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //1. check if user exist in user collection in database according to their id

    final GoogleSignInAccount user = googleSignIn
        .currentUser; //return current user and initialize it to user var
    DocumentSnapshot doc = await usersRef.doc(user.id).get(); //to get users id

    //2. if the user does not exist then take them to create account page

    if (!doc.exists) {
      //to check if the user exist or not
      final username = await Navigator.push(
          //gets username from create account
          context,
          MaterialPageRoute(
            builder: (context) => CreateAccount(),
          ));

      //3. get username from create account, use it to make new user document in user collection

      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.doc(user.id).get(); //update the doc variable

    }

    //store the current user from user model
    //so that we can pass the current user data to different pages
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    pageController.dispose(); //when we don't need the controller
    super.dispose();
  }

  //Log in
  login() {
    googleSignIn.signIn(); //for sign_in with google
  }

  //sign out
  logout() {
    googleSignIn.signOut(); //for logging out
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    //responsible for changing page in page view
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(profileId: currentUser?.id),
          // RaisedButton(
          //   child: Text("Logout"),
          //   onPressed: logout,
          // ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged, //takes index of page controller
        physics: NeverScrollableScrollPhysics(), //user cant scroll
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          //bottom navigation bar items
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.teal, Colors.deepPurple,Colors.red],//Colors.redAccent
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                login();
              },
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

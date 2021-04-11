import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/widgets/custom_image.dart';
import 'package:flutter_application/widgets/header.dart';
import 'package:flutter_application/widgets/post.dart';
import 'package:flutter_application/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';

class Timeline extends StatefulWidget {
  final String profileId;

  Timeline({this.profileId});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildTimeline() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 260.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Post",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        // drawer: Drawer(
        //   child: ListView(
        //     children: [
        //       // UserAccountsDrawerHeader(
        //       //   accountName: Text(currentUser.displayName),
        //       //   accountEmail: Text(currentUser.email),
        //       //   currentAccountPicture: CircleAvatar(
        //       //     backgroundImage: NetworkImage(currentUser.photoUrl),
        //       //   ),
        //       // ),
        //       Divider(),
        //       ListTile(
        //         title: Text("Logout"),
        //         trailing: Icon(Icons.logout),
        //         onTap: () => googleSignIn.signOut(),
        //       )
        //     ],
        //   ),
        // ),
        body: RefreshIndicator(
          onRefresh: () => getTimeline(),
          child: buildTimeline(),
        ));
  }
}

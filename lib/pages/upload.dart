import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {

  final User currentUser; //to get current user
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  Position _currentPosition; //for getting users current location information
  String _currentAddress;

  TextEditingController locationController = TextEditingController();  //for location input
  TextEditingController captionController = TextEditingController();   //for caption input

  bool isUploading = false;

  File file; //to initialize the file for uploading photo from device
  final picker = ImagePicker();

  String postId = Uuid().v4();  //unique string for the post id

  handleTakePhoto() async {  //to upload photo from camera
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future handleChooseFromGallery() async {  //to upload photo from gallery
    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
        print("File Loaded");
      } else {
        print('No image selected.');
      }
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(   //pop up for showing the dialog
          title: Text("Create Post"),
          children: [
            SimpleDialogOption(
              child: Text("Photo With Camera"),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text("Image from Gallery"),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme
          .of(context)
          .accentColor
          .withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;  //if file is null build splash screen
    });
  }

  compressImage() async {  //to compress the image
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));  //image quality
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("post_$postId.jpg")
        .putFile(imageFile);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;  //to get download url and according to it show results
  }

  createPostInFirestore(  //for storing the posts in fire-store
      {String mediaUrl, String location, String description}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }


  handleSubmit() async {
    setState(() {
      isUploading = true; //is uploading true, show linear progress
    });

    await compressImage();  //to compress the image, since image can be of high quality
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      isUploading = false;
      file = null;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            //doubt
            onPressed: isUploading ? null : () => handleSubmit(),  //if is uploading is true then disable button

            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          )
        ],
      ),

      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(""),  //if isUploading is true then show linear progress
          Container(
            height: 220.0,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
              CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: () => _getCurrentLocation(),
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() {  //to get device's current location
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      //locationController.text = _currentAddress;
      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
         locationController.text = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}

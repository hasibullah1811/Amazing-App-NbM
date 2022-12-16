import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:amazing_app/services/facial_api_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

class FaceApiScreen extends StatefulWidget {
  static const String routeName = "FaceApiScreen";

  @override
  _FaceApiScreenState createState() => _FaceApiScreenState();
}

class _FaceApiScreenState extends State<FaceApiScreen> {
  Map<String, dynamic> profilePicMap = {};
  String profilePicLocalAddress = '';
  FaceApiServices? faceApiServices;
  bool imagesSet = false;
  bool testing = false;

  @override
  void initState() {
    super.initState();

    // initPlatformState();
    Future.delayed(Duration.zero, () async {
      //your async 'await' codes goes here
      if (!testing) await getProfilePicAndSetInitialImgToCompare();
      // else await get
      // await matchFaces();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    faceApiServices = Provider.of<FaceApiServices>(context);
  }

  getProfilePicAndSetInitialImgToCompare() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePref = prefs.getString('profilePic');
    Map<String, dynamic> FileMap =
        jsonDecode(imagePref!) as Map<String, dynamic>;
    profilePicMap = FileMap;
    profilePicLocalAddress = profilePicMap.values.elementAt(0).toString();
    print(profilePicLocalAddress);
    faceApiServices?.setImage(
        true,
        io.File(profilePicLocalAddress).readAsBytesSync(),
        Regula.ImageType.PRINTED);

    await matchFaces();
  }

  initializeCameraToCompareImage() async {
    Regula.FaceSDK.presentFaceCaptureActivity().then((result) {
      faceApiServices?.setImage(
          false,
          base64Decode(Regula.FaceCaptureResponse.fromJson(json.decode(result))!
              .image!
              .bitmap!
              .replaceAll("\n", "")),
          Regula.ImageType.LIVE);
      faceApiServices?.matchFaces(context);
    });

    // setState(() {
    //   imagesSet = true;
    // });
  }

  matchFaces() async {
    if (!imagesSet) {
      await initializeCameraToCompareImage();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/face_scan_animation.json',
              width: 150,
              height: 150,
              fit: BoxFit.fill,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text('Matching Faces.... Please wait'),
            ),
          ),
        ],
      ));
}

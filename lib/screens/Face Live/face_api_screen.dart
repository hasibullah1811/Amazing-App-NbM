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
  // var image1 = new Regula.MatchFacesImage();
  // var image2 = new Regula.MatchFacesImage();
  // var img1 = Image.asset('assets/images/portrait.png');
  // var img2 = Image.asset('assets/images/portrait.png');
  // String _similarity = "nil";
  // String _liveness = "nil";
  Map<String, dynamic> profilePicMap = {};
  String profilePicLocalAddress = '';
  FaceApiServices? faceApiServices;
  bool imagesSet = false;
  // late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(vsync: this);

    initPlatformState();
    getProfilePicAndSetInitialImgToCompare();
    // initializeCameraToCompareImage();
    Future.delayed(Duration.zero, () async {
      //your async 'await' codes goes here
      await matchFaces();
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
    setState(() {});
  }

  initializeCameraToCompareImage() async {
    Regula.FaceSDK.presentFaceCaptureActivity().then((result) =>
        faceApiServices?.setImage(
            false,
            base64Decode(
                Regula.FaceCaptureResponse.fromJson(json.decode(result))!
                    .image!
                    .bitmap!
                    .replaceAll("\n", "")),
            Regula.ImageType.LIVE));

    setState(() {
      imagesSet = true;
    });
    faceApiServices?.matchFaces(context);
  }

  matchFaces() async {
    if (!imagesSet) {
      await initializeCameraToCompareImage();
    }
  }

  Future<void> initPlatformState() async {}

  showAlertDialog(BuildContext context, bool first) => showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(title: Text("Select option"), actions: [
            // ignore: deprecated_member_use
            TextButton(
                child: Text("Use gallery"),
                onPressed: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((value) => {
                            faceApiServices?.setImage(
                                first,
                                io.File(value!.path).readAsBytesSync(),
                                Regula.ImageType.PRINTED)
                          });
                }),
            // ignore: deprecated_member_use
            TextButton(
                child: Text("Use camera"),
                onPressed: () {
                  Regula.FaceSDK.presentFaceCaptureActivity().then((result) =>
                      faceApiServices?.setImage(
                          first,
                          base64Decode(Regula.FaceCaptureResponse.fromJson(
                                  json.decode(result))!
                              .image!
                              .bitmap!
                              .replaceAll("\n", "")),
                          Regula.ImageType.LIVE));
                  Navigator.pop(context);
                })
          ]));

  // setImage(bool first, Uint8List? imageFile, int type) {
  //   if (imageFile == null) return;
  //   setState(() => _similarity = "nil");
  //   if (first) {
  //     image1.bitmap = base64Encode(imageFile);
  //     image1.imageType = type;
  //     setState(() {
  //       img1 = Image.memory(imageFile);
  //       _liveness = "nil";
  //     });
  //   } else {
  //     image2.bitmap = base64Encode(imageFile);
  //     image2.imageType = type;
  //     setState(() => img2 = Image.memory(imageFile));
  //   }
  // }

  // clearResults() {
  //   setState(() {
  //     img1 = Image.asset('assets/images/portrait.png');
  //     img2 = Image.asset('assets/images/portrait.png');
  //     _similarity = "nil";
  //     _liveness = "nil";
  //   });
  //   image1 = new Regula.MatchFacesImage();
  //   image2 = new Regula.MatchFacesImage();
  // }

  // matchFaces() {
  //   if (image1.bitmap == null ||
  //       image1.bitmap == "" ||
  //       image2.bitmap == null ||
  //       image2.bitmap == "") return;
  //   setState(() => _similarity = "Processing...");
  //   var request = new Regula.MatchFacesRequest();
  //   request.images = [image1, image2];
  //   Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
  //     var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
  //     Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
  //             jsonEncode(response!.results), 0.75)
  //         .then((str) {
  //       var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
  //           json.decode(str));
  //       setState(() => _similarity = split!.matchedFaces.length > 0
  //           ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
  //               "%")
  //           : "error");
  //     });
  //   });
  // }

  // liveness() => Regula.FaceSDK.startLiveness().then((value) {
  //       var result = Regula.LivenessResponse.fromJson(json.decode(value));
  //       setImage(true, base64Decode(result!.bitmap!.replaceAll("\n", "")),
  //           Regula.ImageType.LIVE);
  //       setState(() => _liveness = result.liveness == 0 ? "passed" : "unknown");
  //     });

  Widget createButton(String text, VoidCallback onPress) => Container(
        // ignore: deprecated_member_use
        child: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
            ),
            onPressed: onPress,
            child: Text(text)),
        width: 250,
      );

  Widget createImage(image, VoidCallback onPress) => Material(
          child: InkWell(
        onTap: onPress,
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image(height: 150, width: 150, image: image),
          ),
        ),
      ));

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Matching Faces.... Please wait'),
            ),
          ),
        ],
      )

          // : Container(
          //     margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
          //     width: double.infinity,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         createImage(faceApiServices!.img1.image,
          //             () => showAlertDialog(context, true)),
          //         createImage(faceApiServices!.img2.image,
          //             () => showAlertDialog(context, false)),
          //         Container(margin: EdgeInsets.fromLTRB(0, 0, 0, 15)),
          //         createButton(
          //             "Match", () => faceApiServices?.matchFaces(context)),
          //         createButton("Liveness", () => faceApiServices?.liveness()),
          //         createButton(
          //             "Clear", () => faceApiServices?.clearResults()),
          //         Container(
          //           margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Text("Similarity: " + faceApiServices!.similarity,
          //                   style: TextStyle(fontSize: 18)),
          //               Container(margin: EdgeInsets.fromLTRB(20, 0, 0, 0)),
          //               Text("Liveness: " + faceApiServices!.islive,
          //                   style: TextStyle(fontSize: 18))
          //             ],
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          );
}

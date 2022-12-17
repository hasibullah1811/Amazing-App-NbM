import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/capture_face_live.dart';
import 'package:amazing_app/screens/capture_face_screen.dart';
import 'package:amazing_app/screens/display_picture_screen.dart';
import 'package:amazing_app/screens/landing_screen.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' as regula;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:path_provider/path_provider.dart';

class CaptureFaceInstructionScreen extends StatefulWidget {
  static const String routeName = "CaptureFaceInstructionScreen";

  const CaptureFaceInstructionScreen({
    super.key,
  });

  @override
  State<CaptureFaceInstructionScreen> createState() =>
      _CaptureFaceInstructionScreenState();
}

class _CaptureFaceInstructionScreenState
    extends State<CaptureFaceInstructionScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  String imagePath = '';
  bool imageSet = false;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  var img1 = Image.asset('assets/images/portrait.png');
  var img2 = Image.asset('assets/images/portrait.png');
  String savedPath = '';
  bool _isLive = false;
  AuthService? authService;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // initPlatformState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
  }

  setImage(bool first, Uint8List? imageFile, int type) async {
    if (imageFile == null) return;
    // setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      File rawImg = File.fromRawPath(imageFile);
      if (await Permission.storage.request().isGranted) {
        final tempDir = await getTemporaryDirectory();
        final file =
            await File('${tempDir.path}/${authService!.userUID}_image.jpg')
                .create();
        file.writeAsBytesSync(imageFile);
        rawImg = file;
      }

      setState(() {
        img1 = Image.memory(imageFile);
        imageSet = true;
        print("****** SAVED PATH : " + rawImg.path);
        savedPath = rawImg.path;
        // _liveness = "nil";
      });
      // await authService!.uploadPic(authService!.user.user.uid, rawImg);
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      setState(() => img2 = Image.memory(imageFile));
    }
  }

  Future<void> initPlatformState() async {}

  // liveness() => regula.FaceSDK.startLiveness().then((value) {
  //       var result = regula.LivenessResponse.fromJson(json.decode(value));
  //       setImage(
  //         true,
  //         base64Decode(result?.bitmap?.replaceAll("\n", "") as String),
  //         regula.ImageType.LIVE,
  //       );
  //       setState(() => _isLive = result?.liveness == 0 ? true : false);
  //     });

  liveness() {
    {
      ImagePicker().pickImage(source: ImageSource.camera).then((value) => {
            setImage(true, File(value!.path).readAsBytesSync(),
                regula.ImageType.PRINTED)
          });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Face Authentication',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'We need to scan your face so that we can ensure 100% security of your files',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => DisplayPictureScreen(
                                imagePath: savedPath,
                                image: img1.image,
                              )),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          savedPath,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              createImage(img1.image, () => showAlertDialog(context, true)),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Smile and Continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () async {
                    if (imageSet) {
                      authService
                          ?.uploadPic(authService!.userUID, savedPath)
                          .then((value) {
                        Navigator.popAndPushNamed(
                            context, LandingScreen.routeName);
                      });
                    } else {
                      regula.FaceSDK.presentFaceCaptureActivity().then(
                        (result) {
                          setImage(
                              true,
                              base64Decode(regula.FaceCaptureResponse.fromJson(
                                      json.decode(result))!
                                  .image!
                                  .bitmap!
                                  .replaceAll("\n", "")),
                              regula.ImageType.LIVE);
                        },
                      );
                    }
                  },
                  child: authService!.loading
                      ? CupertinoActivityIndicator()
                      : CustomButtonLarge(
                          title: imageSet ? 'Upload' : 'Continue'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget createImage(image, VoidCallback onPress) => Material(
          child: InkWell(
        onTap: onPress,
        child: Container(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image(height: 150, width: 150, image: image),
              ),
            ],
          ),
        ),
      ));

  showAlertDialog(BuildContext context, bool first) => showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(title: Text("Select option"), actions: [
            // ignore: deprecated_member_use
            // TextButton(
            //     child: Text("Use gallery"),
            //     onPressed: () {
            //       ImagePicker().pickImage(source: ImageSource.gallery).then(
            //           (value) => {
            //                 setImage(first, File(value!.path).readAsBytesSync(),
            //                     regula.ImageType.PRINTED)
            //               });
            //     }),
            // ignore: deprecated_member_use
            TextButton(
                child: Text("Use camera"),
                onPressed: () async {
                  regula.FaceSDK.presentFaceCaptureActivity().then(
                    (result) {
                      setImage(
                          first,
                          base64Decode(regula.FaceCaptureResponse.fromJson(
                                  json.decode(result))!
                              .image!
                              .bitmap!
                              .replaceAll("\n", "")),
                          regula.ImageType.LIVE);
                    },
                  );

                  // Navigator.pop(context);
                })
          ]));
}

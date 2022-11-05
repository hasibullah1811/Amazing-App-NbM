import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/capture_face_screen.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' as regula;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
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
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  var img1 = Image.asset('assets/images/portrait.png');
  var img2 = Image.asset('assets/images/portrait.png');
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

  setImage(
      bool first, Uint8List? imageFile, int type, File rawImageFile) async {
    if (imageFile == null) return;
    // setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      File rawImg = File.fromRawPath(imageFile);
      setState(() {
        img1 = Image.memory(imageFile);
        // _liveness = "nil";
      });
      await authService!.uploadPic(authService!.user.user.uid, rawImageFile);
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      setState(() => img2 = Image.memory(imageFile));
    }
  }

  setImageOld(
    bool first,
    List<int> imageFile,
    int type,
    File rawImageFile,
  ) {
    if (imageFile == null) return;
    // setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      setState(() async {
        img1 = Image.memory(Uint8List.fromList(imageFile));

        // // File image conversion
        // Uint8List imageInUnit8List =
        //     Uint8List.fromList(imageFile); // store unit8List image here ;
        // final tempDir = await getTemporaryDirectory();
        // File file = await File('${tempDir.path}/image.png').create();
        // file.writeAsBytesSync(imageInUnit8List);

        // log(file.path);
        // _liveness = "nil";

        _isLive = false;
      });
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      setState(() => img2 = Image.memory(Uint8List.fromList(imageFile)));
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

  liveness() async {
    ImagePicker().pickImage(source: ImageSource.camera).then((value) => {
          setImage(
            true,
            File(value!.path).readAsBytesSync(),
            regula.ImageType.PRINTED,
            File(value!.path),
          )
        });
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
                ],
              ),
              Center(
                child: Lottie.asset(
                  'assets/animations/face_scan_animation.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                  controller: _controller,
                  onLoaded: (composition) {
                    // Configure the AnimationController with the duration of the
                    // Lottie file and start the animation.
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),
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
                    onTap: liveness,
                    child: CustomButtonLarge(title: 'Continue')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

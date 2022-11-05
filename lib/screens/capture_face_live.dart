import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:image_picker/image_picker.dart';

class CaptureFaceLive extends StatefulWidget {
  const CaptureFaceLive({super.key});
  static const String routeName = "CaptureFaceLive";

  @override
  State<CaptureFaceLive> createState() => _CaptureFaceLiveState();
}

class _CaptureFaceLiveState extends State<CaptureFaceLive> {
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  var img1 = Image.asset('assets/images/portrait.png');
  var img2 = Image.asset('assets/images/portrait.png');
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  setImage(bool first, List<int> imageFile, int type) {
    if (imageFile == null) return;
    // setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      // setState(() {
      //   img1 = Image.memory(Uint8List.fromList(imageFile));
      //   // _liveness = "nil";
      //   _isLive = false;
      // });
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      // setState(() => img2 = Image.memory(Uint8List.fromList(imageFile)));
    }
  }

  Future<void> initPlatformState() async {}

  liveness() => regula.FaceSDK.startLiveness().then((value) {
        var result = regula.LivenessResponse.fromJson(json.decode(value));
        // setImage(
        //     true,
        //     base64Decode(result?.bitmap?.replaceAll("\n", "") as String),
        //     regula.ImageType.LIVE);
        setState(() => _isLive = result?.liveness == 0 ? true : false);
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('is live: $_isLive'),
            ),
            // const Spacer(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: (() => liveness()),
                child: const Text('Test Liveness'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

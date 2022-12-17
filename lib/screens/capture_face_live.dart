import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/test_service.dart';

class CaptureFaceTestLab extends StatefulWidget {
  late final String mainImageUrl;
  static const String routeName = "CaptureFaceTestLab";
  @override
  _CaptureFaceTestLab createState() => _CaptureFaceTestLab();
}

class _CaptureFaceTestLab extends State<CaptureFaceTestLab> {
  var image1 = new regula.MatchFacesImage();
  var image2 = new regula.MatchFacesImage();
  var img1 = Image.asset('assets/images/portrait.png');
  var img2 = Image.asset('assets/images/portrait.png');
  String _similarity = "nil";
  String _liveness = "nil";
  late TestService testService;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    testService = Provider.of<TestService>(context);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
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
                            setImage(
                                first,
                                io.File(value!.path).readAsBytesSync(),
                                regula.ImageType.PRINTED)
                          });
                }),
            // ignore: deprecated_member_use
            TextButton(
                child: Text("Use camera"),
                onPressed: () {
                  regula.FaceSDK.presentFaceCaptureActivity().then((result) =>
                      setImage(
                          first,
                          base64Decode(regula.FaceCaptureResponse.fromJson(
                                  json.decode(result))!
                              .image!
                              .bitmap!
                              .replaceAll("\n", "")),
                          regula.ImageType.LIVE));
                  Navigator.pop(context);
                })
          ]));

  setImage(bool first, Uint8List? imageFile, int type) {
    if (imageFile == null) return;
    setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(testService.mainImagebytes);
      image1.imageType = type;
      setState(() {
        img1 = Image.memory(testService.mainImagebytes);
        _liveness = "nil";
      });
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      setState(() => img2 = Image.memory(imageFile));
    }
  }

  clearResults() {
    setState(() {
      img1 = Image.asset('assets/images/portrait.png');
      img2 = Image.asset('assets/images/portrait.png');
      _similarity = "nil";
      _liveness = "nil";
    });
    image1 = new regula.MatchFacesImage();
    image2 = new regula.MatchFacesImage();
  }

  matchFaces() {
    if (image1.bitmap == null ||
        image1.bitmap == "" ||
        image2.bitmap == null ||
        image2.bitmap == "") return;
    setState(() => _similarity = "Processing...");
    var request = new regula.MatchFacesRequest();
    request.images = [image1, image2];
    regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      regula.FaceSDK.matchFacesSimilarityThresholdSplit(
              jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        setState(() => _similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
                "%")
            : "Not Matched");
      });
    });
  }

  liveness() => regula.FaceSDK.startLiveness().then((value) {
        var result = regula.LivenessResponse.fromJson(json.decode(value));
        setImage(true, base64Decode(result!.bitmap!.replaceAll("\n", "")),
            regula.ImageType.LIVE);
        setState(() => _liveness = result.liveness == 0 ? "passed" : "unknown");
      });

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
        appBar: AppBar(
          elevation: 0.0,
        ),
        body: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
            width: double.infinity,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text('Tap on the first box to set Initial Image'),
                      ),
                      createImage(img1.image, () {
                        setImage(true, testService.mainImagebytes,
                            regula.ImageType.PRINTED);
                      }),
                    ],
                  ),
                  Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tap on the second box to set the Image to compare',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      createImage(
                          img2.image, () => showAlertDialog(context, false)),
                    ],
                  ),
                  Container(margin: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  createButton("Match", () => matchFaces()),
                  // createButton("Liveness", () => liveness()),
                  createButton("Clear", () => clearResults()),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Similarity: " + _similarity,
                              style: TextStyle(fontSize: 18)),
                          Container(margin: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                          Text("Liveness: " + _liveness,
                              style: TextStyle(fontSize: 18))
                        ],
                      ))
                ])),
      );
}

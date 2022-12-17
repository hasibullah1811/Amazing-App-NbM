import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;

class FaceApiServices with ChangeNotifier {
  bool matchingInProgress = false;

  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();
  var img1 = Image.asset('assets/images/portrait.png');
  var img2 = Image.asset('assets/images/portrait.png');
  String similarity = "nil";
  String islive = "nil";
  bool faceMatched = false;

  setImage(bool first, Uint8List? imageFile, int type) {
    if (imageFile == null) return;
    similarity = "nil";
    notifyListeners();
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;

      img1 = Image.memory(imageFile);
      islive = "nil";
      notifyListeners();
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      img2 = Image.memory(imageFile);
      notifyListeners();
    }
  }

  clearResults() {
    // img1 = Image.asset('assets/images/portrait.png');
    // img2 = Image.asset('assets/images/portrait.png');
    similarity = "nil";
    islive = "nil";
    matchingInProgress = false;
    faceMatched = false;
    notifyListeners();
    // image1 = new Regula.MatchFacesImage();
    // image2 = new Regula.MatchFacesImage();
  }

  matchFaces(BuildContext context) {
    if (image1.bitmap == null ||
        image1.bitmap == "" ||
        image2.bitmap == null ||
        image2.bitmap == "") return;
    similarity = "Processing...";
    matchingInProgress = true;
    // faceMatched = false;
    notifyListeners();

    var request = Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
              jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
                "%")
            : "error";

        if (similarity == "error") {
          faceMatched = false;
          SnackBar snackBar = const SnackBar(
            content: Text('Fatch did not match, try again'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          matchingInProgress = false;
          notifyListeners();
          clearResults();
          Navigator.pop(context, false);
        } else {
          faceMatched = true;
          matchingInProgress = false;
          SnackBar snackBar = SnackBar(
            content: Text('Fatch matched with ${similarity}Similarity'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          notifyListeners();
          clearResults();
          Navigator.pop(context, true);
        }
        notifyListeners();
      });
    });
  }

  liveness() => Regula.FaceSDK.startLiveness().then((value) {
        var result = Regula.LivenessResponse.fromJson(json.decode(value));
        setImage(true, base64Decode(result!.bitmap!.replaceAll("\n", "")),
            Regula.ImageType.LIVE);
        islive = result.liveness == 0 ? "passed" : "unknown";
        notifyListeners();
      });
}

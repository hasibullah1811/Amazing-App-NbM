import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/services.dart';

class TestService with ChangeNotifier {
  late client.Dio dio;
  List<String> userPhotos = [];
  late Uint8List mainImagebytes;

  TestService() {
    dio = client.Dio();
  }

  fetchPhotos() async {
    userPhotos = [];
    var res = await dio.get(
        'https://amazing-app-backend-production.up.railway.app/api/getProfile/getAllImageLinks');
    if (res.statusCode == 200) {
      var userData = res.data;
      userData.forEach((element) {
        if (element != null && element != "") {
          userPhotos.add(element);
        }
      });
      userPhotos.forEach((element) {
        print(element);
      });
    }
    notifyListeners();
    // final testUserPhotos = testUserPhotosFromJson(res.data.toString());
    // print(testUserPhotos);
  }

  updateInitialTestImage(String mainImgUrl) async {
    mainImagebytes =
        (await NetworkAssetBundle(Uri.parse(mainImgUrl)).load(mainImgUrl))
            .buffer
            .asUint8List();
    notifyListeners();
  }
}

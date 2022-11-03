import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService with ChangeNotifier {
  late CameraDescription camera;

  void getCamera(CameraDescription firstCamera) {
    camera = firstCamera;
  }
}

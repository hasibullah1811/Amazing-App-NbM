import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/services/camera_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CaptureFaceScreen extends StatefulWidget {
  static const String routeName = "CaptureFaceScreen";
  final List<CameraDescription> cameras;

  const CaptureFaceScreen({super.key, required this.cameras});

  @override
  State<CaptureFaceScreen> createState() => _CaptureFaceScreenState();
}

class _CaptureFaceScreenState extends State<CaptureFaceScreen> {
  late CameraController cameraController;
  late Future<void> cameraValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startCamera();
  }

  void startCamera() async {
    cameraController = CameraController(
        widget.cameras[1], ResolutionPreset.high,
        enableAudio: false);
    cameraValue = cameraController.initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: CameraPreview(cameraController));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Load a Lottie file from your assets
                Lottie.asset('assets/animations/face_scan_animation.json'),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButtonLarge(title: "Capture"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

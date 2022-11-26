import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:amazing_app/services/camera_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_iOS_style_bottom_sheet.dart';
import 'display_picture_screen.dart';

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
  AuthService? authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startCamera();
    Future.delayed(Duration.zero, () async {
      getModalWindow(context);
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
  }

  void startCamera() async {
    cameraController = CameraController(
        widget.cameras[1], ResolutionPreset.high,
        enableAudio: false);
    cameraValue = cameraController.initialize();
  }

  void getModalWindow(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true, // to full height
      // useSafeArea: true, // to show under status bar
      backgroundColor: Colors.transparent, // to show BorderRadius of Container
      context: context,
      builder: (BuildContext context) {
        return IOSModalStyle(
          childBody: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text('Instructions',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('1. Position your face in the frame',
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('2. Hold Still',
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('3. Capture your picture',
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  captureFrame() async {
    try {
      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await cameraController.takePicture();
      print(image.path);
      if (!mounted) return;
      // If the picture was taken, display it on a new screen.
      // await Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => DisplayPictureScreen(
      //       // Pass the automatically generated path to
      //       // the DisplayPictureScreen widget.
      //       imagePath: image.path,
      //     ),
      //   ),
      // );
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () {
            captureFrame();
          },
          child: CustomButtonLarge(
            title: 'Capture Frame',
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(cameraController);
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
                Lottie.asset(
                  'assets/animations/green-scanner.json',
                  height: size.height * 0.7,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/capture_face_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
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
                    onTap: () {
                      Navigator.pushNamed(context, CaptureFaceScreen.routeName);
                    },
                    child: CustomButtonLarge(title: 'Continue')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

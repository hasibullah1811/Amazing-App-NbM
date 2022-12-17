import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/capture_face_screen.dart';
import 'package:amazing_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

import 'capture_face_live.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "HomeScreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, CaptureFaceScreen.routeName);
                  },
                  child: CustomButtonLarge(title: 'Capture Image Screen'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, CaptureFaceScreen.routeName);
                  },
                  child: CustomButtonLarge(title: 'Capture Image Screen'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                  child: CustomButtonLarge(title: 'Google Sign In'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, CaptureFaceTestLab.routeName);
                  },
                  child: CustomButtonLarge(title: 'Capture With Liveness'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

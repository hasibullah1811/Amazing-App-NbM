import 'dart:ui';

import 'package:amazing_app/screens/Face%20Live/face_api_screen.dart';
import 'package:amazing_app/screens/downloaded_file_screen.dart';
import 'package:amazing_app/screens/landing_screen.dart';
import 'package:amazing_app/screens/login_screen.dart';
import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/screens/capture_face_screen.dart';
import 'package:amazing_app/screens/onboarding_screen.dart';
import 'package:amazing_app/screens/test_face_recognition.dart';
import 'package:amazing_app/services/camera_service.dart';
import 'package:amazing_app/services/facial_api_service.dart';
import 'package:amazing_app/services/file_service.dart';
import 'package:amazing_app/services/google_drive_service.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/capture_face_live.dart';
import 'services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/test_service.dart';

bool? isViewed;
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = prefs.getBool('viewed_onboard');
  final cameras = await availableCameras();
  runApp(
    MyApp(
      cameras: cameras,
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CameraService()),
        ChangeNotifierProvider(create: (_) => FaceApiServices()),
        ChangeNotifierProvider(create: (_) => GoogleDriveService()),
        ChangeNotifierProvider(create: (_) => FileService()),
        ChangeNotifierProvider(create: (_) => TestService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Amazing App',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Montserrat'),
        // home: const LoginScreen(),
        home: isViewed != true ? const OnboardingScreen() : const LoginScreen(),
        routes: {
          HomeScreen.routeName: ((context) => const HomeScreen()),
          CaptureFaceInstructionScreen.routeName: ((context) =>
              const CaptureFaceInstructionScreen()),
          CaptureFaceScreen.routeName: (context) => CaptureFaceScreen(
                cameras: cameras,
              ),
          LoginScreen.routeName: (context) => const LoginScreen(),
          CaptureFaceTestLab.routeName: (context) => CaptureFaceTestLab(),
          OnboardingScreen.routeName: (context) => const OnboardingScreen(),
          LandingScreen.routeName: (context) => const LandingScreen(),
          FaceApiScreen.routeName: (context) => FaceApiScreen(),
          TestFaceRecognition.routeName: (context) => TestFaceRecognition(),
          DownloadedFileScreen.routeName: (context) =>
              const DownloadedFileScreen(),
        },
      ),
    );
  }
}

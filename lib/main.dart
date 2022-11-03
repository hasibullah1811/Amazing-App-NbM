import 'package:amazing_app/screens/login_screen.dart';
import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/screens/capture_face_screen.dart';
import 'package:amazing_app/services/camera_service.dart';
import 'package:camera/camera.dart';
import 'screens/capture_face_live.dart';
import 'screens/onboarding_screen.dart';
import 'services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'package:amazing_app/screens/onboarding_screen.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Amazing App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: const HomeScreen(),
        home: const HomeScreen(),
        routes: {
          HomeScreen.routeName: ((context) => const HomeScreen()),
          CaptureFaceInstructionScreen.routeName: ((context) =>
              const CaptureFaceInstructionScreen()),
          CaptureFaceScreen.routeName: (context) => CaptureFaceScreen(
                cameras: cameras,
              ),
          LoginScreen.routeName: (context) => const LoginScreen(),
          CaptureFaceLive.routeName: (context) => CaptureFaceLive(),
          "OnboardingScreen": (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}

import 'dart:developer';

import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/screens/drive_upload_screen.dart';
import 'package:amazing_app/screens/landing_screen.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/google_signin.dart';
import 'capture_face_live.dart';
import 'capture_face_screen.dart';
import 'loggedin_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "LoginScreen";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthService authService;
  bool screenLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (!screenLoaded) {
      authService = Provider.of<AuthService>(context);
      GoogleSignInAccount? currentUser = authService.googleSignIn.currentUser;
      authService.googleSignIn.onCurrentUserChanged
          .listen((GoogleSignInAccount? account) {
        currentUser = account;
        if (currentUser != null) {
          print('Silent Sign In');
          print(currentUser!.email.toString());
          authService.currentUser = currentUser;
          Navigator.pushNamed(context, LandingScreen.routeName);
          // Navigator.pushNamed(context, DriveUploadScreen.routeName);
        }
      });
      authService.googleSignIn.signInSilently();
    }
    screenLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screenLoaded
          ? SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Welcome to the Amazing App',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Lottie.asset(
                      'assets/animations/google-icon.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Please sign in with your google account to continue',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () async {
                        await authService.googleSignInNew();
                        Navigator.pushNamed(context, LandingScreen.routeName);
                        // if (authService.pictureUploaded) {
                        //   Navigator.pushNamed(
                        //     context,
                        //     LandingScreen.routeName,
                        //   );
                        // } else {
                        //   Navigator.pushNamed(
                        //     context,
                        //     CaptureFaceInstructionScreen.routeName,
                        //   );
                        // }
                      },
                      child: CustomButtonLarge(title: 'Sign In'),
                    ),
                  ),
                  // _signInContainer(),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
    );
  }

  Widget _signInContainer() {
    return Center(
      child: Container(
        height: 200,
        child: Column(
          children: [
            authService.signedIn
                ? Column(
                    children: [
                      Text(authService.user.user.email),
                      Text(authService.user.user.displayName),
                    ],
                  )
                : Container(),
            authService.signedIn
                ? const Text("Signed In")
                : const Text('Not Signed In'),
            ElevatedButton(
                onPressed: () async {
                  await authService.googleSignInNew();
                  if (authService.pictureUploaded) {
                    Navigator.pushNamed(
                      context,
                      LandingScreen.routeName,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      CaptureFaceInstructionScreen.routeName,
                    );
                  }
                },
                child: const Text("Sign In with Google"))
          ],
        ),
      ),
    );
  }

  // Future _signIn() async {
  //   final u = await GoogleSignInApi.login();
  //   User user = User(user: u!.displayName as String, email: u.email);

  //   if (u == null) {
  //     print('failed');
  //   } else {
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(
  //       builder: (context) => LoggedInPage(user: user),
  //     ));
  //   }
  // print(user.toString());
  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> LoggedInPage(user: user)))
}

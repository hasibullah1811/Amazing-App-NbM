import 'dart:developer';

import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/google_signin.dart';
import 'capture_face_live.dart';
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
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (!screenLoaded) {
      authService = Provider.of<AuthService>(context);
    }
    screenLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenLoaded
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _signInContainer(),
              ],
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
                  Navigator.pushNamed(
                    context,
                    CaptureFaceInstructionScreen.routeName,
                  );
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

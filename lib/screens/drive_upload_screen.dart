import 'dart:io';

import 'package:amazing_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'landing_screen.dart';

class DriveUploadScreen extends StatefulWidget {
  const DriveUploadScreen({super.key});
  static const routeName = "DriveUploadScreen";

  @override
  State<DriveUploadScreen> createState() => _DriveUploadScreenState();
}

class _DriveUploadScreenState extends State<DriveUploadScreen> {
  late AuthService authService;
  bool screenLoaded = false;

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
          // Navigator.pushNamed(context, LandingScreen.routeName);
        }
      });
      authService.googleSignIn.signInSilently();
      
    }
    screenLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    
    return Visibility(
      visible: screenLoaded,
      child: Scaffold(
        body: Center(
            child: ElevatedButton(
          child: const Text('Upload'),
          onPressed: () async {
            // await authService.googleSignInNew();
            final path = await FlutterDocumentPicker.openDocument();
            // print(path);
            // var googleDrive = GoogleDrive();
            // googleDrive.upload(File(path as String));
            try {
              var id = await authService
                  .uploadFilesToGoogleDrive(File(path as String));
              print('id : $id');
            } catch (error) {
              print('error occured');
            } finally {
              print('uploaded');
            }
          },
        )),
      
      ),
    );
  }
}

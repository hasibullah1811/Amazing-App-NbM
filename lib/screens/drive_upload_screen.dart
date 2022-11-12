import 'dart:convert';
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
        child: Column(children: [
          SizedBox(
            height: 200,
          ),
          ElevatedButton(
            child: const Text('Upload'),
            onPressed: () async {
              // await authService.googleSignInNew();
              final path = await FlutterDocumentPicker.openDocument();
              File newFile = File(path as String);
              final dataBytes = await newFile.readAsBytes();
              final bytesBase = base64Encode(dataBytes);
              print(bytesBase);
              // print(path);
              // var googleDrive = GoogleDrive();
              // googleDrive.upload(File(path as String));
              try {
                var id = await authService.uploadFilesToGoogleDrive(newFile);
                print('id : $id');
                // var all_files = await authService.
              } catch (error) {
                print('error occured');
              } finally {
                print('uploaded');
              }
            },
          ),
          ElevatedButton(
              onPressed: () async {
                final files_list =
                    await authService.getAllFilesFromGoogleDrive();
                print(files_list);
              },
              child: Text("Get List of files")),
          ElevatedButton(
              onPressed: () async {
                final files_list =
                    await authService.getAllFilesFromGoogleDrive();
                print(files_list);
              },
              child: Text("Get List of files other api")),
          ElevatedButton(
              onPressed: () async {
                final files_list = await authService.createFolder();
                print(files_list);
              },
              child: Text("Create Folder")),
          ElevatedButton(
              onPressed: () async {
                final files_list = await authService.getDrives();
                print(files_list);
              },
              child: Text("Get Drives")),
          // ElevatedButton(
          //     onPressed: () async {
          //       await authService.
          //     },
          //     child: Text("Get List")),
        ]),
      )),
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/custom_widgets/custom_drawer.dart';
import 'package:amazing_app/screens/Face%20Live/face_api_screen.dart';
import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/screens/capture_face_live.dart';
import 'package:amazing_app/screens/login_screen.dart';
import 'package:amazing_app/screens/open_file_screen.dart';
import 'package:amazing_app/screens/test_face_recognition.dart';
import 'package:amazing_app/services/file_service.dart';
import 'package:amazing_app/services/google_drive_service.dart';
import 'package:amazing_app/services/test_service.dart';
import 'package:amazing_app/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'downloaded_file_screen.dart';
import 'files_list_screen.dart';

class LandingScreen extends StatefulWidget {
  static const String routeName = "Landing Screen";
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late AuthService authService;
  late GoogleDriveService googleDriveService;
  late FileService fileService;
  late TestService testService;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
    googleDriveService = Provider.of<GoogleDriveService>(context);
    fileService = Provider.of<FileService>(context);
    testService = Provider.of<TestService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: CustomDrawer(
        authService: authService,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _drawerKey.currentState?.openDrawer(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(
                                CupertinoIcons.line_horizontal_3,
                              ),
                            ),
                          ),
                          if (authService.currentUser!.photoUrl != null)
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: CachedNetworkImageProvider(
                                  authService.currentUser!.photoUrl.toString()),
                            )
                          else
                            SizedBox(
                              height: 43,
                              child: Image.asset("assets/images/portrait.png"),
                            )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 16.0,
                        ),
                        child: InkWell(
                          onTap: () async {
                            final files_list = await googleDriveService
                                .getAllFileFromGoogleDriveFromSpaceId("root");
                            print(files_list);
                            googleDriveService.progressPercentage = 0;
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => FilesListScreen()),
                              ),
                            );
                          },
                          child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width * 0.40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                              gradient: LinearGradient(
                                colors: [
                                  primaryColorLight,
                                  primaryColorLight.withOpacity(0.8)
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Google\nDrive',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.file_open_sharp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Upload, Download, Browse Files on your google Drive',
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 16.0,
                        ),
                        child: InkWell(
                          onTap: () async {
                            final files_list =
                                await fileService.getDownloadedFileList();
                            print(files_list);
                            googleDriveService.progressPercentage = 0;
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) =>
                                    const DownloadedFileScreen()),
                              ),
                            );
                          },
                          child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width * 0.40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                              gradient: LinearGradient(
                                colors: [
                                  primaryColorLight,
                                  primaryColorLight.withOpacity(0.8)
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Recent\nFiles',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.downloading_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Browse Files that your recently download on your Device',
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  authService.loading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                      : Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  // onTap: () async {
                  //   await authService.handleSignOut();
                  //   if (!mounted) return;
                  //   Navigator.pushReplacementNamed(
                  //       context, LoginScreen.routeName);
                  // },
                  child: Text(
                    '© Amazing App 2021. Version: +1.0.1 Alpha',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

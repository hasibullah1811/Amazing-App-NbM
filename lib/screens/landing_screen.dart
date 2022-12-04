import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/Face%20Live/face_api_screen.dart';
import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/screens/capture_face_live.dart';
import 'package:amazing_app/screens/login_screen.dart';
import 'package:amazing_app/screens/open_file_screen.dart';
import 'package:amazing_app/services/google_drive_service.dart';
import 'package:amazing_app/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
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
  late List<FileSystemEntity> entities;
  //Declare Globaly
  late String directory;
  late List file;

  // Make New Function
  void _listofFiles() async {
    directory = "/storage/emulated/0/Android/data"; //Give your folder path
    setState(() {
      file = Directory("$directory/downloads/")
          .listSync(); //use your folder name insted of resume.
    });

    log(file.length.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
    googleDriveService = Provider.of<GoogleDriveService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authService.currentUser!.displayName
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  authService.currentUser!.email.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                authService.currentUser!.photoUrl.toString(),
                                errorListener: () => const Icon(Icons.error),

                                //     Icon(Icons.error),,
                                // progressIndicatorBuilder:
                                //     (context, url, downloadProgress) =>
                                //         CircularProgressIndicator(
                                //   strokeWidth: 2,
                                //   value: downloadProgress.progress,
                                // ),
                                // height: 40,
                                // width: 40,
                                // errorWidget: (context, url, error) =>
                                //     Icon(Icons.error),
                              ),
                            ),
                          ],
                        ),
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
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Files',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.file_open_sharp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Browse Files on your google Drive',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.lock_open),
                          ),
                          Text(
                            'Recently Decrypted Files',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () async {
                        final fatchMatched = await Navigator.pushNamed(
                            context, FaceApiScreen.routeName);

                        if (fatchMatched == true) {
                          log('FatchMatched');
                        }
                      },
                      child: CustomButtonLarge(title: 'Face Liveness'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, CaptureFaceInstructionScreen.routeName);
                      },
                      child: CustomButtonLarge(
                        title: 'Capture Face Instruction',
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Container(
                  //     height: 200,
                  //     width: double.infinity,
                  //     child: ListView.builder(
                  //       itemCount: fil.length,
                  //       itemBuilder: (BuildContext context, int index) {
                  //         String key = fileMap.keys.elementAt(index);
                  //         return new Column(
                  //           children: <Widget>[
                  //             new ListTile(
                  //               onTap: () {
                  //                 // Navigator.push(context, MaterialPageRoute(builder: ((context) => OpenFileScreen(imageFile: (imageFile), mimeType: mimeType) ));
                  //               },
                  //               title: new Text("$key"),
                  //               subtitle: new Text("${fileMap[key]}"),
                  //               // trailing: Container(
                  //               //   decoration: BoxDecoration(
                  //               //     borderRadius: BorderRadius.circular(8),
                  //               //     color: Colors.green.withOpacity(0.4),
                  //               //   )F,
                  //               //   child: Padding(
                  //               //     padding: const EdgeInsets.all(8.0),
                  //               //     child: Text(
                  //               //       'View',
                  //               //     ),
                  //               //   ),
                  //               // ),
                  //             ),
                  //             new Divider(
                  //               height: 2.0,
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // )
                ],
              ),
              Column(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 64.0, right: 64.0, top: 16.0, bottom: 16.0),
                  //   child: InkWell(
                  //     onTap: () async {
                  //       final files_list = await authService
                  //           .getAllFileFromGoogleDriveFromSpaceId("root");
                  //       print(files_list);
                  //       authService.progressPercentage = 0;
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: ((context) =>
                  //               FilesListScreen(fileList: files_list)),
                  //         ),
                  //       );
                  //     },
                  //     child: CustomButtonLarge(
                  //       title: "Browse Files on your google drive",
                  //       color: Colors.blue.withOpacity(0.8),
                  //     ),
                  //   ),
                  // ),

                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 64.0, right: 64.0, top: 16.0, bottom: 16.0),
                  //   child: InkWell(
                  //     onTap: () async {
                  //       // We will show the downloaded file here for encryption and decryption
                  //       // _pickFile();
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: ((context) =>
                  //                   DownloadedFilesScreen())));
                  //     },
                  //     child: CustomButtonLarge(
                  //       title: "Downloaded Files",
                  //       color: Colors.green.withOpacity(0.8),
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Text(
                  //     'Welcome to your account, Exciting features coming soon',
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  // authService.progressPercentage != 0
                  //     ? Padding(
                  //         padding: const EdgeInsets.all(16.0),
                  //         child: Text(
                  //           'Progress: ${authService.progressPercentage} %',
                  //           textAlign: TextAlign.center,
                  //         ),
                  //       )
                  //     : Container(),
                  authService.loading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                      : Container(),
                  // : Column(
                  //     children: [
                  //       Icon(
                  //         CupertinoIcons.exclamationmark_circle,
                  //         color: primaryColorLight,
                  //         size: 40,
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.all(16.0),
                  //         child: Text(
                  //           'Looks like you have not finished the account setup. Please complete account setup by taking your picture',
                  //           textAlign: TextAlign.center,
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           Navigator.pushNamed(context,
                  //               CaptureFaceInstructionScreen.routeName);
                  //         },
                  //         child: Container(
                  //           width: 150,
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(8.0),
                  //             color: Colors.orange.withOpacity(0.6),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(12.0),
                  //             child: Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Text('Continue Setup'),
                  //                 Icon(
                  //                   CupertinoIcons.chevron_right,
                  //                   size: 20,
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () async {
                    await authService.handleSignOut();
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  },
                  child: CustomButtonLarge(title: 'Sign Out'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

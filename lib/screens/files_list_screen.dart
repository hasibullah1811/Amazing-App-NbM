import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:amazing_app/services/google_drive_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/facial_api_service.dart';
import '../services/file.dart';
import '../utils/constant_functions.dart';
import 'Face Live/face_api_screen.dart';
import 'open_file_screen.dart';

import 'package:mime_type/mime_type.dart';

class FilesListScreen extends StatefulWidget {
  static const String routeName = "Landing Screen";
  final List<GoogleDriveFileMetaData> fileList;
  final bool? uploading;
  final String currentId;

  const FilesListScreen(
      {super.key,
      required this.fileList,
      this.uploading = false,
      this.currentId = "root"});

  @override
  State<FilesListScreen> createState() => _FilesListScreenState();
}

class _FilesListScreenState extends State<FilesListScreen> {
  late AuthService authService;
  late GoogleDriveService googleDriveService;
  FaceApiServices? faceApiServices;

  final spinkit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.green,
        ),
      );
    },
  );

  static const snackBar = SnackBar(
    content: Text('File downloaded successfully!'),
  );
  static const uploadSnackBar = SnackBar(
    content: Text('File Uploaded successfully!'),
  );
  static const errorSnackBar = SnackBar(
    content: Text('Error Occured!'),
  );
  static const faceNotMatchedSnackBar = SnackBar(
    content: Text('Oops! Your face is not matched. Are you trying to steal?'),
  );

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
    faceApiServices = Provider.of<FaceApiServices>(context);
    googleDriveService = Provider.of<GoogleDriveService>(context);
  }

  Future<File> _pickFile() async {
    //With parameters:
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
      allowedFileExtensions: ['jpg', 'pdf', 'doc'],
      allowedMimeTypes: ['application/*'],
      invalidFileNameSymbols: ['/'],
    );
    final path = await FlutterDocumentPicker.openDocument();
    File newFile = File(path as String);
    return newFile;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Checks if the face is matched
          faceApiServices!.faceMatched = false;
          faceApiServices!.similarity = 'nill';

          // final fatchMatched =
          // await Navigator.pushNamed(context, FaceApiScreen.routeName);
          // if (fatchMatched == true) {
          File newFile = await _pickFile();
          try {
            log('FatchMatched');
            await googleDriveService
                .encryptFile(newFile)
                .then((encryptedFile) async {
              await googleDriveService
                  .uploadFilesToGoogleDrive(encryptedFile!, widget.currentId)
                  .then((id) {
                print('uploaded');
                ScaffoldMessenger.of(context).showSnackBar(uploadSnackBar);
                googleDriveService.progressPercentage = 0;
                print('id : $id');
              });
            });
            // File encryptedFile = await googleDriveService.encryptFile(newFile);
            // var id = await googleDriveService.uploadFilesToGoogleDrive(
            //     encryptedFile!, widget.currentId);
            // print('uploaded');
            // ScaffoldMessenger.of(context).showSnackBar(uploadSnackBar);
            // googleDriveService.progressPercentage = 0;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
            print('upload Error');
          }
          // }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Google Drive Files',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                googleDriveService.fileSavedLocation.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.green.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'File saved on location: ${googleDriveService.fileSavedLocation}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                googleDriveService.progressPercentage != 0
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Progress: ${googleDriveService.progressPercentage} %',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
                googleDriveService.fileList[widget.currentId] != null
                    ? 
                    Container(
                        height: 500,
                        width: size.width,
                        child: ListView.builder(
                            itemCount: widget.fileList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.blue[50]),
                                  child: googleDriveService
                                              .fileList[widget.currentId] !=
                                          null
                                      ? ListTile(
                                          iconColor: Colors.blue,
                                          leading: widget.fileList[index]
                                                      .mimeType !=
                                                  "application/vnd.google-apps.folder"
                                              ? IconButton(
                                                  onPressed: () async {
                                                    print(
                                                      widget.fileList[index].id
                                                          .toString(),
                                                    );
                                                    //Checks if the face is matched
                                                    // final fatchMatched =
                                                    //     await Navigator.pushNamed(context,
                                                    //         FaceApiScreen.routeName);

                                                    // if (fatchMatched == true) {
                                                    File? newFile =
                                                        await googleDriveService
                                                            .downloadFile(
                                                      widget.fileList[index].id
                                                          .toString(),
                                                      context,
                                                      widget
                                                          .fileList[index].name
                                                          .toString(),
                                                    );

                                                    var fileType = widget
                                                        .fileList[index].name
                                                        .toString()
                                                        .substring(widget
                                                                .fileList[index]
                                                                .name
                                                                .toString()
                                                                .length -
                                                            3);

                                                    File? decryptedFile;
                                                    if (fileType == 'aes') {
                                                      decryptedFile =
                                                          await googleDriveService
                                                              .decryptFile(
                                                        newFile!,
                                                      );
                                                    } else {
                                                      decryptedFile = newFile!;
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: ((context) =>
                                                            OpenFileScreen(
                                                              imageFile:
                                                                  decryptedFile!,
                                                              mimeType: mime(
                                                                      decryptedFile
                                                                          .path)
                                                                  as String,
                                                            )),
                                                      ),
                                                    );
                                                    // } else {
                                                    //   ScaffoldMessenger.of(context)
                                                    //       .showSnackBar(
                                                    //           faceNotMatchedSnackBar);
                                                    // }
                                                  },
                                                  icon: const Icon(
                                                      CupertinoIcons
                                                          .cloud_download),
                                                )
                                              : IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                      CupertinoIcons.folder)),
                                          subtitle: Text(getFormattedDate(widget
                                              .fileList[index].modifiedTime
                                              .toString())),
                                          trailing: widget.fileList[index]
                                                      .mimeType !=
                                                  "application/vnd.google-apps.folder"
                                              ? Text(
                                                  formatBytes(
                                                      widget.fileList[index]
                                                              .size ??
                                                          0 as int,
                                                      2),
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                )
                                              : const Text(''),
                                          title: GestureDetector(
                                            onTap: () async {
                                              if (widget.fileList[index]
                                                      .mimeType ==
                                                  "application/vnd.google-apps.folder") {
                                                final files_list =
                                                    await googleDriveService
                                                        .getAllFileFromGoogleDriveFromSpaceId(
                                                            widget
                                                                .fileList[index]
                                                                .id as String);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        FilesListScreen(
                                                          fileList: files_list,
                                                          currentId: widget
                                                              .fileList[index]
                                                              .id as String,
                                                        )),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              widget.fileList[index].name
                                                  .toString(),
                                            ),
                                          ),
                                        )
                                      : const CircularProgressIndicator(),
                                ),
                              );
                            }),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
            googleDriveService.isEncrypting
                ? Center(
                    child: Container(
                    height: 200,
                    width: size.width - 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text('Encrypting... Please don\'t close the app.'),
                    ),
                  ))
                : Container(),
            googleDriveService.isDecrypting
                ? Center(
                    child: Container(
                    height: 200,
                    width: size.width - 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text('Decrypting... Please don\'t close the app.'),
                    ),
                  ))
                : Container(),
          ],
        ),
      ),
    );
  }
}

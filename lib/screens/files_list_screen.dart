import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:amazing_app/services/google_drive_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/facial_api_service.dart';
import '../utils/constant_functions.dart';
import 'Face Live/face_api_screen.dart';
import 'open_file_screen.dart';

import 'package:mime_type/mime_type.dart';

class FilesListScreen extends StatefulWidget {
  static const String routeName = "Landing Screen";
  // final List<GoogleDriveFileMetaData> fileList;
  final bool? uploading;
  final String currentId;

  const FilesListScreen(
      {super.key,
      // required this.fileList,
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
      return const DecoratedBox(
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

  static showSnackbar(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['jpg', 'pdf', 'doc', 'docx', 'png', 'jpeg'],
        allowedMimeTypes: ['application/*'],
        invalidFileNameSymbols: ['/'],
      );
      final path = await FlutterDocumentPicker.openDocument();
      File newFile = File(path as String);
      return newFile;
    } catch (e) {
      print(e);
      return File("");
    }
  }

  Future<bool> _faceMatch() async {
    //comment out this line for face recognition.
    // return true;

    faceApiServices!.faceMatched = false;
    faceApiServices!.similarity = 'nill';

    final faceMatched =
        await Navigator.pushNamed(context, FaceApiScreen.routeName);
    return faceMatched as bool;
  }

  _uploadFile() async {
    if (await _faceMatch() == true) {
      File newFile = await _pickFile();
      try {
        log('FatchMatched');
        await googleDriveService
            .encryptFile(newFile)
            .then((encryptedFile) async {
          await googleDriveService
              .uploadFilesToGoogleDrive(encryptedFile, widget.currentId)
              .then((id) {
            print('uploaded');
            ScaffoldMessenger.of(context).showSnackBar(uploadSnackBar);

            print('id : $id');
          });
        });
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
        showSnackbar(context, errorSnackBar);
        print('upload Error');
      }
    }
  }

  _downloadFile(int index) async {
    if (await _faceMatch() == true) {
      File? newFile = await googleDriveService.downloadFile(
        googleDriveService.fileList[widget.currentId]?[index].id.toString()
            as String,
        context,
        googleDriveService.fileList[widget.currentId]?[index].name.toString()
            as String,
      );

      var fileType = googleDriveService.fileList[widget.currentId]?[index].name
          .toString()
          .substring((googleDriveService.fileList[widget.currentId]?[index].name
                  .toString()
                  .length as int) -
              3);

      File? decryptedFile;
      if (fileType == 'aes') {
        decryptedFile = await googleDriveService.decryptFile(
          newFile!,
        );
      } else {
        decryptedFile = newFile!;
      }

      if (!mounted) return;
      showSnackbar(context, snackBar);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => OpenFileScreen(
                file: decryptedFile!,
                mimeType: mime(decryptedFile.path) as String,
              )),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(faceNotMatchedSnackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          _uploadFile();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Google Drive Files',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                googleDriveService.progressPercentage != 0
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: size.width * 0.80,
                              child: LinearProgressIndicator(
                                value:
                                    googleDriveService.progressPercentage / 100,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${googleDriveService.progressPercentage} %',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Container(),
                googleDriveService.fileList[widget.currentId] != null
                    ? SizedBox(
                        height: size.height * 0.8,
                        width: size.width,
                        child: ListView.builder(
                            itemCount: googleDriveService
                                .fileList[widget.currentId]?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.orange[100]!,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: googleDriveService
                                              .fileList[widget.currentId] !=
                                          null
                                      ? GestureDetector(
                                          onTap: () async {
                                            if (googleDriveService
                                                    .fileList[widget.currentId]
                                                        ?[index]
                                                    .mimeType ==
                                                "application/vnd.google-apps.folder") {
                                              await googleDriveService
                                                  .getAllFileFromGoogleDriveFromSpaceId(
                                                      googleDriveService
                                                          .fileList[
                                                              widget.currentId]
                                                              ?[index]
                                                          .id as String);
                                              if (!mounted) return;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: ((context) =>
                                                      FilesListScreen(
                                                        // fileList: files_list,
                                                        currentId:
                                                            googleDriveService
                                                                .fileList[widget
                                                                        .currentId]
                                                                    ?[index]
                                                                .id as String,
                                                      )),
                                                ),
                                              );
                                            }
                                          },
                                          child: ListTile(
                                            iconColor: Colors.amber,
                                            leading: googleDriveService
                                                        .fileList[widget
                                                            .currentId]?[index]
                                                        .mimeType !=
                                                    "application/vnd.google-apps.folder"
                                                ? IconButton(
                                                    onPressed: () async {
                                                      _downloadFile(index);
                                                    },
                                                    icon: const Icon(
                                                        CupertinoIcons
                                                            .cloud_download),
                                                  )
                                                : IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                        CupertinoIcons.folder)),
                                            subtitle: Text(getFormattedDate(
                                                googleDriveService
                                                    .fileList[widget.currentId]
                                                        ?[index]
                                                    .modifiedTime
                                                    .toString() as String)),
                                            trailing: googleDriveService
                                                        .fileList[widget
                                                            .currentId]?[index]
                                                        .mimeType !=
                                                    "application/vnd.google-apps.folder"
                                                ? Text(
                                                    formatBytes(
                                                        googleDriveService
                                                                .fileList[widget
                                                                        .currentId]
                                                                    ?[index]
                                                                .size ??
                                                            0,
                                                        2),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  )
                                                : const Text(''),
                                            title: Text(
                                              googleDriveService
                                                  .fileList[widget.currentId]
                                                      ?[index]
                                                  .name
                                                  .toString() as String,
                                            ),
                                          ))
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

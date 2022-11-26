import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
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
          try {
            //Checks if the face is matched
            final fatchMatched =
                await Navigator.pushNamed(context, FaceApiScreen.routeName);

            if (fatchMatched == true) {
              log('FatchMatched');
              File newFile = await _pickFile();
              File encryptedFile = await authService.encryptFile(newFile);
              var id = await authService.uploadFilesToGoogleDrive(
                  encryptedFile!, widget.currentId);
              print('uploaded');
              ScaffoldMessenger.of(context).showSnackBar(uploadSnackBar);
              authService.progressPercentage = 0;
              print('id : $id');
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(faceNotMatchedSnackBar);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
            print('upload Error');
          }
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
                authService.fileSavedLocation.isNotEmpty
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
                                'File saved on location: ${authService.fileSavedLocation}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                authService.progressPercentage != 0
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Progress: ${authService.progressPercentage} %',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
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
                            child: ListTile(
                              iconColor: Colors.blue,
                              leading: widget.fileList[index].mimeType !=
                                      "application/vnd.google-apps.folder"
                                  ? IconButton(
                                      onPressed: () async {
                                        // print(widget.fileList[index].mimeType);
                                        /*
                                        application/pdf
                                        image/jpeg
                                        application/vnd.openxmlformats-officedocument.wordprocessingml.document - docx
                                        application/vnd.google-apps.document - google doc
                                        */
                                        print(
                                          widget.fileList[index].id.toString(),
                                        );
                                        File? newFile =
                                            await authService.downloadFile(
                                          widget.fileList[index].id.toString(),
                                          context,
                                          widget.fileList[index].name
                                              .toString(),
                                        );

                                        var fileType = widget
                                            .fileList[index].name
                                            .toString()
                                            .substring(widget
                                                    .fileList[index].name
                                                    .toString()
                                                    .length -
                                                3);

                                        File? decryptedFile;
                                        if (fileType == 'aes') {
                                          decryptedFile =
                                              await authService.decryptFile(
                                            newFile!,
                                          );
                                        } else {
                                          decryptedFile = newFile!;
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                OpenFileScreen(
                                                  imageFile: decryptedFile!,
                                                  mimeType:
                                                      mime(decryptedFile.path)
                                                          as String,
                                                )),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          CupertinoIcons.cloud_download),
                                    )
                                  : IconButton(
                                      onPressed: () {},
                                      icon: const Icon(CupertinoIcons.folder)),
                              subtitle: Text(getFormattedDate(widget
                                  .fileList[index].modifiedTime
                                  .toString())),
                              trailing: widget.fileList[index].mimeType !=
                                      "application/vnd.google-apps.folder"
                                  ? Text(
                                      formatBytes(
                                          widget.fileList[index].size ??
                                              0 as int,
                                          2),
                                      style: TextStyle(fontSize: 14),
                                    )
                                  : const Text(''),
                              title: GestureDetector(
                                onTap: () async {
                                  if (widget.fileList[index].mimeType ==
                                      "application/vnd.google-apps.folder") {
                                    final files_list = await authService
                                        .getAllFileFromGoogleDriveFromSpaceId(
                                            widget.fileList[index].id
                                                as String);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) => FilesListScreen(
                                              fileList: files_list,
                                              currentId: widget
                                                  .fileList[index].id as String,
                                            )),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  widget.fileList[index].name.toString(),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
            authService.isEncrypting
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                : Container(),
            authService.isDecrypting
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

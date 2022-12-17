import 'dart:io';

import 'package:amazing_app/custom_widgets/custom_list_tile_file.dart';
import 'package:amazing_app/services/facial_api_service.dart';
import 'package:amazing_app/services/file_service.dart';
import 'package:amazing_app/services/google_drive_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mime_type/mime_type.dart';
import 'package:provider/provider.dart';

import 'Face Live/face_api_screen.dart';
import 'open_file_screen.dart';

class DownloadedFileScreen extends StatefulWidget {
  const DownloadedFileScreen({super.key});
  static const String routeName = "Downloads Screen";

  @override
  State<DownloadedFileScreen> createState() => _DownloadedFileScreenState();
}

class _DownloadedFileScreenState extends State<DownloadedFileScreen> {
  late FileService fileService;
  late GoogleDriveService googleDriveService;
  late FaceApiServices faceApiServices;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fileService = Provider.of<FileService>(context);
    googleDriveService = Provider.of<GoogleDriveService>(context);
    faceApiServices = Provider.of<FaceApiServices>(context);
  }

  String getName(String path) {
    var split = path.split("/");
    return split[split.length - 1];
  }

  Future<bool> _faceMatch() async {
    //comment out this line for face recognition.
    // return true;

    faceApiServices.faceMatched = false;
    faceApiServices.similarity = 'nill';

    final faceMatched =
        await Navigator.pushNamed(context, FaceApiScreen.routeName);
    return faceMatched as bool;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: const Text(
          'Downloads',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
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
            ListView.builder(
              itemBuilder: (context, index) {
                return CustomListTileFile(
                  title: getName(fileService.files[index].absolute.path),
                  onTap: () async {
                    if (await _faceMatch()) {
                      File? decryptedFile;

                      var fileType = fileService.files[index].absolute.path
                          .split(".")
                          .last;
                      if (fileType == 'aes') {
                        decryptedFile = await googleDriveService.decryptFile(
                          File(fileService.files[index].absolute.path),
                        );
                      } else {
                        decryptedFile =
                            File(fileService.files[index].absolute.path);
                      }
                      print(mime(fileService.files[index].absolute.path));
                      if (!mounted) return;
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
                      SnackBar snackBar =
                          const SnackBar(content: Text("Face not matched"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  isEncrypted:
                      mime(fileService.files[index].absolute.path) == null,
                  // isDownloaded: true,
                );
              },
              itemCount: fileService.files.length,
            ),
          ],
        ),
      ),
    );
  }
}

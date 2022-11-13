import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../con/constant_functions.dart';
import '../services/auth_service.dart';
import '../services/file.dart';

class FilesListScreen extends StatefulWidget {
  static const String routeName = "Landing Screen";
  final List<GoogleDriveFileMetaData> fileList;

  const FilesListScreen({super.key, required this.fileList});

  @override
  State<FilesListScreen> createState() => _FilesListScreenState();
}

class _FilesListScreenState extends State<FilesListScreen> {
  late AuthService authService;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
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
                  itemCount: 20,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.blue[50]),
                        child: ListTile(
                          iconColor: Colors.blue,
                          leading: IconButton(
                            onPressed: () async {
                              print(
                                widget.fileList[index].id.toString(),
                              );
                              File file = await authService.downloadFile(
                                widget.fileList[index].id.toString(),
                                context,
                              );
                              // OpenFile.open(file.path);
                            },
                            icon: const Icon(CupertinoIcons.cloud_download),
                          ),
                          subtitle: Text(getFormattedDate(
                              widget.fileList[index].modifiedTime.toString())),
                          trailing: Text(
                            formatBytes(
                                widget.fileList[index].size ?? 0 as int, 2),
                            style: TextStyle(fontSize: 14),
                          ),
                          title: Text(
                            widget.fileList[index].name.toString(),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

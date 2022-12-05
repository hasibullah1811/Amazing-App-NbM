import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class FileService with ChangeNotifier {
  // Directory directory;
  bool isLoaded = false;
  late Directory directory;
  late List<FileSystemEntity> files;
  getDownloadedFileList() async {
    directory = (await getExternalStorageDirectory())!;
    files = Directory("${directory.path}/")
        .listSync(); //use your folder name insted of resume.
    isLoaded = true;
    notifyListeners();
    for (var file in files) {
      print(file);
    }
  }
}

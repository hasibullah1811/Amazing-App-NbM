import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:amazing_app/services/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as path;

class GoogleDriveService with ChangeNotifier {
  bool signedIn = false;
  bool isEncrypting = false;
  bool loading = true;
  bool isDecrypting = false;
  int progressPercentage = 0;
  late Map<String, List<GoogleDriveFileMetaData>> fileList;
  // String currentParent = 'root';
  String fileSavedLocation = '';
  late Map<String, dynamic> fileMap = {};
  late AuthService authService;

  // GoogleDriveService(this.authService);
  GoogleDriveService() {
    authService = AuthService();
    fileList = {};
  }

  retrieveDownloadedFileLocal() async {
    Directory? newPath = await getExternalStorageDirectory();
    final dir = Directory(newPath?.path as String);
    final List<FileSystemEntity> entities = await dir.list().toList();
    return entities;
  }

  saveDownloadedFileLocal(String fileName, String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> downloadedFile = {
      fileName: filePath,
    };

    bool result =
        await prefs.setString('downloadedFile', jsonEncode(downloadedFile));
    if (result) {
      print('*********File Downloaded Saved Local Storage*********');
    }
  }

  Future<List<GoogleDriveFileMetaData>> getAllFileFromGoogleDriveFromSpaceId(
      String id) async {
    loading = true;
    notifyListeners();
    var googleDriveClient = await authService.getGoogleDriveClient();
    fileList[id] = await googleDriveClient.listSpaceFolder(id);
    loading = false;
    notifyListeners();
    return fileList[id]!;
  }

  Future createFolder(String folderName) async {
    final driveApi = await _getDriveApi();
    final driveFile = drive.File();
    driveFile.mimeType = "application/vnd.google-apps.folder";
    driveFile.name = folderName;

    final folder = driveApi?.files.create(driveFile);
    print(folder);
  }

  Future getDrives() async {
    final driveApi = await _getDriveApi();
    final drives = await driveApi?.drives.list();
    drive.DriveList? driveList = drives as drive.DriveList;

    if (driveList != null) {
      print(driveList.drives);
      driveList.drives?.forEach((element) {
        print(element.name);
      });
    }

    return driveList;
  }

  Future<File?> downloadFile(
      String fileId, BuildContext context, String file_name) async {
    if (await Permission.storage.request().isGranted) {
      loading = true;
      progressPercentage = 0;
      notifyListeners();
      var googleDriveClient = await authService.getGoogleDriveClient();
      Directory? newPath = await getExternalStorageDirectory();
      final filePath = "${newPath?.path}/$file_name";
      final fileExist = await File(filePath).exists();
      if (fileExist) {
        loading = false;
        notifyListeners();
        return File(filePath);
      } else {
        File file = await googleDriveClient.download(fileId, file_name,
            onDownloadProgress: (i, l) {
          print('$i/$l');
          progressPercentage = ((i / l) * 100).floor();
          notifyListeners();
        });
        final newFile = await saveFile(file_name, file);
        loading = false;
        notifyListeners();
        progressPercentage = 0;
        notifyListeners();
        return newFile;
      }
    }
    return null;
  }

  Future saveFile(String fileName, File file) async {
    String path = await getFilePath(fileName);
    Directory? newPath = await getExternalStorageDirectory();

    file.copy('${newPath?.path}/$fileName');
    File newFile = File('${newPath?.path}/$fileName');
    print('saved file: ${fileName}');
    print('new path: ${newPath?.path}/$fileName');

    return newFile;
  }

  Future<File> decryptFile(File file) async {
    isDecrypting = true;
    notifyListeners();
    final directories = await getExternalCacheDirectories();
    final baseName = path.basename(file.path);
    final nameWithoutAes = baseName.substring(0, baseName.length - 4);
    print(nameWithoutAes);

    final filePathFull = "${directories?.first.path}/$nameWithoutAes";
    final fileExist = await File(filePathFull).exists();
    if (authService.currentUser == null) await authService.getGoogleAuth();
    String? decryptedFilePath;
    if (!fileExist) {
      AesCrypt crypt = AesCrypt();
      crypt.aesSetMode(AesMode.cbc);
      crypt.setOverwriteMode(AesCryptOwMode.rename);
      crypt.setPassword(authService.currentUser!.id);
      try {
        decryptedFilePath = await crypt.decryptFile(file.path, filePathFull);
        print(decryptedFilePath);
      } catch (e) {
        print('error decrypting');
      }
    } else {
      decryptedFilePath = filePathFull;
      saveDownloadedFileLocal(nameWithoutAes, decryptedFilePath);
    }

    isDecrypting = false;
    notifyListeners();

    return File(decryptedFilePath!);
  }

  Future<File> encryptFile(File file) async {
    isEncrypting = true;
    notifyListeners();
    AesCrypt crypt = AesCrypt();
    crypt.aesSetMode(AesMode.cbc);
    crypt.setPassword(authService.currentUser!.id);

    crypt.setOverwriteMode(AesCryptOwMode.rename);
    String? encryptedFilePath;
    try {
      print('encrypting...');
      encryptedFilePath = await crypt.encryptFile(file.path);
      print('encrypted file path: $encryptedFilePath');
      isEncrypting = false;
    } catch (e) {
      print('encryption error');
      isEncrypting = false;
    }
    isEncrypting = false;
    notifyListeners();
    return File(encryptedFilePath as String);
  }

  Future<String> getFilePath(String fileName) async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/$fileName'; // 3
    return filePath;
  }

  Future<GoogleDriveFileMetaData> getFolderOrFile(String fileId) async {
    var googleDriveClient = await authService.getGoogleDriveClient();
    final file = await googleDriveClient.get(fileId);
    return file;
  }

  Future uploadFilesToGoogleDrive(File file, String parent) async {
    progressPercentage = 0;
    loading = true;
    notifyListeners();
    final fileBaseName = file.absolute.toString();
    final fileN = (fileBaseName.split('/').last);
    final fileName = fileN.split('\'').first;
    var googleDriveClient = await authService.getGoogleDriveClient();

    GoogleDriveFileUploadMetaData metaData = GoogleDriveFileUploadMetaData(
      name: fileName,
    );

    var id = await googleDriveClient.create(metaData, file,
        onUploadProgress: (currentProgress, totalProgress) {
      print('$currentProgress / $totalProgress');
      progressPercentage = ((currentProgress / totalProgress) * 100).floor();
      notifyListeners();
    }, parent: parent);
    fileList[parent] = await getAllFileFromGoogleDriveFromSpaceId(parent);
    loading = false;
    notifyListeners();
    progressPercentage = 0;
    notifyListeners();
    return id;
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await authService.googleSignIn.signIn();
    final headers = await googleUser?.authHeaders;
    if (headers == null) {
      print('not signed in');
      return null;
    }

    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }
}

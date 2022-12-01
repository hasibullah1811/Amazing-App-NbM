import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:amazing_app/services/client.dart';
import 'package:amazing_app/services/file.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http_parser/http_parser.dart';
import 'package:amazing_app/models/user.dart';
import 'package:amazing_app/screens/capture_face_live.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  // https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/1234
  // https://pure-chamber-40901.herokuapp.com/api/auth/signIn
  static String serverURl = 'https://pure-chamber-40901.herokuapp.com/api/';

  late BuildContext navigationContext;
  int progressPercentage = 0;
  String fileSavedLocation = '';
  late Map<String, dynamic> fileMap = {};
  bool loading = false;
  bool signedIn = false;
  bool isEncrypting = false;
  bool isDecrypting = false;
  late client.Dio dio;
  late GoogleSignIn googleSignIn;
  late GoogleSignInAccount? currentUser;
  late User user;
  String userUID = '';
  bool pictureUploaded = false;
  final clientId =
      "925629464605-uh9ri343esng52voe9emqncvhu0i27va.apps.googleusercontent.com";
  final scopes = [
    'email',
    drive.DriveApi.driveFileScope,
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveMetadataScope,
    drive.DriveApi.driveScope,
  ];

  AuthService() {
    dio = client.Dio();
    // httpClient = http.Client();

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android specific code
      googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          drive.DriveApi.driveFileScope,
          drive.DriveApi.driveAppdataScope,
          drive.DriveApi.driveMetadataScope,
          drive.DriveApi.driveScope,
        ],
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      //iOS specific code
      googleSignIn = GoogleSignIn(
        clientId:
            "925629464605-uh9ri343esng52voe9emqncvhu0i27va.apps.googleusercontent.com",
        scopes: [
          'email',
        ],
      );
    } else {
      //web or desktop specific code
    }
  }

  // Future<bool> googleSignIn() {}

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
    // if (result) {
    //   return downloadedFile;
    // }
  }

  saveImageAddressLocal(String fileName, String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> profilePicAddress = {
      fileName: filePath,
    };

    bool result =
        await prefs.setString('profilePic', jsonEncode(profilePicAddress));
    if (result) {
      print('*********File Address Saved Local Storage*********');
    }
    // if (result) {
    //   return downloadedFile;
    // }
  }

  retrieveDownloadedFileLocal() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? filePref = prefs.getString('downloadedFile');
    // fileMap = jsonDecode(filePref!) as Map<String, dynamic>;
    // notifyListeners();
    // return fileMap;
    // List<File> files_list =
    Directory? newPath = await getExternalStorageDirectory();
    final dir = Directory(newPath?.path as String);
    final List<FileSystemEntity> entities = await dir.list().toList();
    return entities;
  }

  googleSignInNew() async {
    loading = true;
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    signedIn = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      await createUser('', googleAuth.accessToken.toString());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await createUser(googleAuth.idToken.toString(), '');
    }
    // Create the User Model
    UserClass userClass = UserClass(
      uid: userUID,
      email: googleUser.email,
      emailVerified: true,
      displayName: googleUser.displayName.toString(),
      isAnonymous: true,
    );
    user = User(user: userClass);
    log('Updated UID' + user.user.uid.toString());
    loading = false;
    notifyListeners();
  }

  Future<List<GoogleDriveFileMetaData>> getAllFilesFromGoogleDrive(
      String? id) async {
    loading = true;
    notifyListeners();
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
    var files;
    if (id != null) {
      files = await googleDriveClient.list();
    } else {
      files = await googleDriveClient.listSpaceFolder(id!);
    }
    loading = false;
    notifyListeners();
    return files;
  }

  Future<List<GoogleDriveFileMetaData>> getAllFileFromGoogleDriveFromSpaceId(
      String id) async {
    loading = true;
    notifyListeners();
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // print('c1');
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
    var files = await googleDriveClient.listSpaceFolder(id);
    loading = false;
    notifyListeners();
    return files;
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
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn().catchError((onError) {});
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      var googleDriveClient =
          GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
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
    String? decryptedFilePath;
    if (!fileExist) {
      AesCrypt crypt = AesCrypt();
      crypt.aesSetMode(AesMode.cbc);
      crypt.setOverwriteMode(AesCryptOwMode.rename);
      crypt.setPassword(currentUser!.id);
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
    crypt.setPassword(currentUser!.id);

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
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
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
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());

    GoogleDriveFileUploadMetaData metaData = GoogleDriveFileUploadMetaData(
      name: fileName,
    );

    var id = await googleDriveClient.create(metaData, file,
        onUploadProgress: (currentProgress, totalProgress) {
      print('$currentProgress / $totalProgress');
      progressPercentage = ((currentProgress / totalProgress) * 100).floor();
      notifyListeners();
    }, parent: parent);
    loading = false;
    notifyListeners();
    return id;
  }

  Future uploadPic(String uid, String filePath) async {
    try {
      //uploads Insurance:
      var formData1 = client.FormData.fromMap({
        'file': await client.MultipartFile.fromFile(filePath,
            filename: DateTime.now().millisecondsSinceEpoch.toString(),
            contentType: MediaType('image', 'png')),
      });

      var res = await dio.post(
        'https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/$uid',
        data: formData1,
        options: client.Options(headers: {
          "Accept": "*/*",
          "Content-Type": "multipart/form-data",
          "Accept-Encoding": "gzip, deflate, br",
          "Connection": "keep-alive"
        }),
      );

      if (res.statusCode == 200) {
        log('Upload Successful');
        saveImageAddressLocal(uid, filePath);
      }
    } catch (e) {
      if (e is client.DioError) print(e.response.toString());
    }
  }

  Future createUser(
    String authIdToken,
    String accessToken,
  ) async {
    try {
      client.Response res = await dio.post(
        "https://pure-chamber-40901.herokuapp.com/api/auth/signIn",
        data: {
          "access_token": accessToken,
          "id_token": authIdToken,
        },
      );
      if (res.statusCode == 200) {
        log('res ${res.data}');
        userUID = res.data['uid'];
        if (res.data['pic'] == '') {
          pictureUploaded = false;
          log('Picture not uploaded');
        } else {
          pictureUploaded = true;
          log('Picture  uploaded');
        }

        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> handleSignOut() => googleSignIn.disconnect();

  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await googleSignIn.signIn();
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

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = new http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

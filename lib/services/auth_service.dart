import 'dart:developer';
import 'dart:io';
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
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AuthService with ChangeNotifier {
  // https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/1234
  // https://pure-chamber-40901.herokuapp.com/api/auth/signIn
  static String serverURl = 'https://pure-chamber-40901.herokuapp.com/api/';

  late BuildContext navigationContext;
  bool loading = false;
  bool signedIn = false;
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

  Future<List<GoogleDriveFileMetaData>> getAllFilesFromGoogleDrive() async {
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // print('c1');
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
    var files = await googleDriveClient.list();
    files.forEach((element) async {
      var file = await googleDriveClient.get(element.id as String);
      print("${file.name} - ${file.id}");
    });
    return files;
  }

  // Future getAllDrives() async {
  //   final GoogleSignInAccount? googleUser =
  //       await googleSignIn.signIn().catchError((onError) {});
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;
  //   // print('c1');
  //   var googleDriveClient =
  //       GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
  //   var drives = await googleDriveClient.driveList();
  // }

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

  Future downloadFile(String fileId) async {
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // print('c1');
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
    final fileForName = await getFolderOrFile(fileId);
    final file = await googleDriveClient.download(fileId, fileForName.name as String,
        onDownloadProgress: (i, l) {
      print('$i/$l');
    });
    final fileBaseName = file.toString();
    final fileName = (fileBaseName.split('/').last);
    saveFile(fileName, file);
    print('saved file: $fileName');
    return file;
  }



  void saveFile(String fileName, File file) async {
    String path = await getFilePath(fileName);
    // final File newFile = await file.copy(path);


    //MODIFY these
    file.writeAsBytes(Uint8List(await file.length()));
    // print('save file location: ${newFile.path}');
  }

  Future<String> getFilePath(String fileName) async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/$fileName'; // 3

    return filePath;
  }

  Future<GoogleDriveFileMetaData> getFolderOrFile(String fileId) async {
    // final driveApi = await _getDriveApi();
    // final folder = driveApi?.files.get(fileId);
    // return folder;
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // print('c1');
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
    final file = await googleDriveClient.get(fileId);
    return file;
  }

  // Future getAllFiles() async {
  //   final driveApi = await _getDriveApi();
  //   final files = driveApi?.files.list();
  //   print(files);
  //   return files;
  // }

  Future uploadFilesToGoogleDrive(File file) async {
    // var googleDrive = ga.DriveApi(authenticatedClient(client.Dio, AccessCredentials.fromJson(json)));
    // final driveApi = await _getDriveApi();
    // print(file);
    final fileBaseName = file.toString();
    final fileName = (fileBaseName.split('/').last);
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // print('c1');
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());

    // print('c2');
    // var driveFile = new drive.File();
    // if (driveFile == null) {
    //   return;
    // }
    // final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
    // driveFile.name = "technical-feeder-$timestamp.jpg";
    // driveFile.modifiedTime = DateTime.now().toUtc();
    // driveFile.parents = ["sifat-upload"];
    // // driveFile.isAppAuthorized = true;
    // driveFile.mimeType = MediaType("image", "jpg") as String?;

    GoogleDriveFileUploadMetaData metaData = GoogleDriveFileUploadMetaData(
      name: fileName,
    );

    // final List<int> content = File(file.path).readAsBytes() as List<int>;
    // print('c3');
    // const contents = "Technical Feeder";
    // final Stream<List<int>> mediaStream =
    //     Future.value(contents.codeUnits).asStream().asBroadcastStream();
    // var media = drive.Media(content, content.length as int);


    // You can also use parent : "id of the folder"

    //Below is an example
    // var id = await googleDriveClient.create(metaData, file,
    //     onUploadProgress: (currentProgress, totalProgress) {
    //   print('$currentProgress / $totalProgress');
    // }, parent: "1mszp0ACsrr7KNbEJLsgQArPs7mHrDDoc");

    var id = await googleDriveClient.create(metaData, file,
        onUploadProgress: (currentProgress, totalProgress) {
      print('$currentProgress / $totalProgress');
    }, parent: "root");
    // print('c4');
    // final response =
    // await driveApi?.files.create(driveFile, uploadMedia: media);
    // return response;
    // return id;
    // }

    // Future uploadFilesToGoogleDrive(String? base, File? file, Uint8List dataBytes) async {
    //   final driveApi = await _getDriveApi();
    //   final driveFile = drive.File();
    //   driveFile.parents = ["root"];
    //   // driveFile.
    //   // Create data here instead of loading a file
    //   final contents = "Technical Feeder";
    //   final Stream<List<int>> mediaStream =
    //       Future.value(dataBytes).asStream().asBroadcastStream();
    //   var media = drive.Media(mediaStream, mediaStream.length as int);

    //   driveFile.name = "test1.jpg";
    //   final response = driveApi?.files.create(driveFile, uploadMedia: media);
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
      // client.Response res = await dio.post(
      //   "https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/$uid",
      // );
      if (res.statusCode == 200) {
        log('Upload Successful');
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
        log('res' + res.data.toString());
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

  //Working for Google Drive
  // Future<drive.DriveApi?> _getDriveApi() async {
  //   final googleUser = await googleSignIn.signIn();
  //   final headers = await googleUser?.authHeaders;
  //   final client = clientViaApiKey("AIzaSyCsnJ0CylOPN9InbzIFPgMsntCl0zEBkv4");
  //   final driveApi = drive.DriveApi(client);
  //   return driveApi;
  // }
  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await googleSignIn.signIn();
    final headers = await googleUser?.authHeaders;
    if (headers == null) {
      // await showMessage(context, "Sign-in first", "Error");
      print('not signed in');
      return null;
    }

    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }

  // Future<void> _showList() async {
  //   final driveApi = await _getDriveApi();
  //   if (driveApi == null) {
  //     return;
  //   }

  //   final fileList = await driveApi.files.list(
  //       spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');
  //   final files = fileList.files;
  //   if (files == null) {
  //     print('no data found in drive');
  //   }

  //   final alert = AlertDialog(
  //     title: Text("Item List"),
  //     content: SingleChildScrollView(
  //       child: ListBody(
  //         children: files?.map((e) => Text(e.name ?? "no-name")).toList(),
  //       ),
  //     ),
  //   );

  //   print('data found');
  // }
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

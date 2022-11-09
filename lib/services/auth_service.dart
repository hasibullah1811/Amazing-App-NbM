import 'dart:developer';
import 'dart:io';
import 'package:amazing_app/services/client.dart';
import 'package:amazing_app/services/file.dart';
import 'package:http_parser/http_parser.dart';
import 'package:amazing_app/models/user.dart';
import 'package:amazing_app/screens/capture_face_live.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:path/path.dart' as path;

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

  AuthService() {
    dio = client.Dio();
    // httpClient = http.Client();

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android specific code
      googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          ga.DriveApi.driveFileScope,
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

  Future uploadFilesToGoogleDrive(File file) async {
    // var googleDrive = ga.DriveApi(authenticatedClient(client.Dio, AccessCredentials.fromJson(json)));
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    print('c1');
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());

    print('c2');
    GoogleDriveFileUploadMetaData metaData = GoogleDriveFileUploadMetaData(
      name: "hello.jpg",
    );
    print('c3');
    var id = await googleDriveClient.create(metaData, file,
        onUploadProgress: (currentProgress, totalProgress) {
      print('$currentProgress / $totalProgress');
    });
    print('c4');
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
}

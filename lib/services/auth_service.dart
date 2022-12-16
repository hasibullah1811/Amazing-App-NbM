import 'dart:convert';
import 'dart:developer';
import 'package:amazing_app/services/client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:amazing_app/models/user.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  // https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/1234
  // https://pure-chamber-40901.herokuapp.com/api/auth/signIn
  // static String serverURl = 'https://pure-chamber-40901.herokuapp.com/api/';
  static String serverURL =
      "https://amazing-app-backend-production.up.railway.app/api/";

  late BuildContext navigationContext;

  bool loading = false;
  bool signedIn = false;
  late client.Dio dio;
  late GoogleSignIn googleSignIn;
  late GoogleSignInAccount? currentUser;
  late User user;
  String userUID = '';
  bool? pictureUploaded;
  // bool pictureUploaded = false;
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
    getGoogleAuth();
  }

  Future<GoogleSignInAuthentication> getGoogleAuth() async {
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    currentUser = googleUser;
    return googleAuth;
  }

  Future<GoogleDriveClient> getGoogleDriveClient() async {
    var googleAuth = await getGoogleAuth();
    var googleDriveClient =
        GoogleDriveClient(dio, token: googleAuth.accessToken.toString());
    return googleDriveClient;
  }

  googleSignInNew() async {
    loading = true;
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    currentUser = googleUser;
    signedIn = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Commenting this code for now
      // uncomment this code when you want to create a new user.
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

  Future uploadPic(String uid, String filePath) async {
    try {
      //uploads Insurance:
      var formData1 = client.FormData.fromMap({
        'file': await client.MultipartFile.fromFile(filePath,
            filename: DateTime.now().millisecondsSinceEpoch.toString(),
            contentType: MediaType('image', 'png')),
      });

      var res = await dio.post(
        "https://amazing-app-backend-production.up.railway.app/api/upload/uploadPic/$uid",
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
        // "https://pure-chamber-40901.herokuapp.com/api/auth/signIn",

        "https://amazing-app-backend-production.up.railway.app/api/auth/signIn",
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
          notifyListeners();
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
  }

  Future<void> handleSignOut() => googleSignIn.disconnect();
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

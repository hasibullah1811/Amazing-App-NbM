import 'dart:developer';

import 'package:amazing_app/models/user.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  // https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/1234
  // https://pure-chamber-40901.herokuapp.com/api/auth/signIn
  static String serverURl = 'https://pure-chamber-40901.herokuapp.com/api/';

  late BuildContext navigationContext;
  bool loading = false;
  bool signedIn = false;
  late client.Dio dio;
  late GoogleSignIn googleSignIn;
  late User user;
  AuthService() {
    dio = client.Dio();
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android specific code
      googleSignIn = GoogleSignIn(
        scopes: [
          'email',
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
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn().catchError((onError) {});
    //final GoogleSignInAccount currentUser = _googleSignIn.currentUser;
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    signedIn = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      createUser('', googleAuth.accessToken.toString());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      createUser(googleAuth.idToken.toString(), '');
    }
    // Create the User Model
    UserClass userClass = UserClass(
      uid: googleUser.id,
      email: googleUser.email,
      emailVerified: true,
      displayName: googleUser.displayName.toString(),
      isAnonymous: true,
    );
    user = User(user: userClass);
    notifyListeners();
  }

  Future uploadPic(String uid) async {
    try {
      client.Response res = await dio.post(
        "https://pure-chamber-40901.herokuapp.com/api/upload/uploadPic/$uid",
      );
      if (res.statusCode == 200) {}
    } catch (e) {
      print(e.toString());
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
        return res.data;
      }
    } catch (e) {
      print(e);
    }
  }
}

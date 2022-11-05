import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/google_signin.dart';
import 'login_screen.dart';

class LoggedInPage extends StatelessWidget {
  LoggedInPage({required this.user, Key? key}) : super(key: key);
  User user;
  @override
  Widget build(BuildContext context) {
    Future _signOut() async {
      await GoogleSignInApi.logout();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    return Scaffold(
      body: Center(
        child: Center(
          child: Container(
            height: 200,
            child: Column(
              children: [
                Text("Signed In"),
                Text(user.user.displayName),
                Text(user.user.email),
                ElevatedButton(onPressed: _signOut, child: Text("Sign Out"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

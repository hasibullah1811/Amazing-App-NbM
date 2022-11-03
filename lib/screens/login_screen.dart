import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/google_signin.dart';
import 'loggedin_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "LoginScreen";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _signInContainer(),
    );
  }

  Widget _signInContainer() {
    return Center(
      child: Container(
        height: 200,
        child: Column(
          children: [
            Text("Not Signed In"),
            ElevatedButton(
                onPressed: _signIn, child: Text("Sign In with Google"))
          ],
        ),
      ),
    );
  }

  Future _signIn() async {
    final u = await GoogleSignInApi.login();
    User user = User(user: u!.displayName as String, email: u.email);

    if (u == null) {
      print('failed');
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoggedInPage(user: user),
      ));
    }
    // print(user.toString());
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> LoggedInPage(user: user)))
  }
}

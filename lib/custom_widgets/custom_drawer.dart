import 'package:amazing_app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/test_face_recognition.dart';

class CustomDrawer extends StatefulWidget {
  final AuthService authService;
  CustomDrawer({
    super.key,
    required this.authService,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context);
                // Get.toNamed('/edit-profile');
              },
              child: DrawerHeader(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authService.currentUser!.displayName
                              .toString(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.authService.currentUser!.email.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // decoration: BoxDecoration(
                //     color:
                //         context.isDarkMode ? primaryColorDark : primaryColorLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Color.fromARGB(255, 31, 170, 103)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    )),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.lab_flask,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      TestFaceRecognition.routeName,
                    );
                  },
                  title: Text(
                    'Test Lab / App Testing',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Sign Out',
              ),
              leading: Icon(CupertinoIcons.lock),
              onTap: () async {
                Navigator.pop(context);
                await widget.authService.handleSignOut();
                // if (!mounted) return;
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              title: Text(
                '© Amazing App 2021. Version: +1.0.1 Alpha',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

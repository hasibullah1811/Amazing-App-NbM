import 'package:amazing_app/custom_widgets/custom_button_large.dart';
import 'package:amazing_app/screens/capture_face_instruction_screen.dart';
import 'package:amazing_app/screens/login_screen.dart';
import 'package:amazing_app/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LandingScreen extends StatefulWidget {
  static const String routeName = "Landing Screen";

  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late AuthService authService;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authService.currentUser!.displayName.toString(),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              authService.currentUser!.email.toString(),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // CircleAvatar(
                        //   radius: 25.0,
                        //   backgroundImage: NetworkImage(
                        //       authService.currentUser!.photoUrl.toString()),
                        //   backgroundColor: Colors.transparent,
                        // )
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Welcome to your account, Exciting features coming soon',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  authService.loading
                      ? CircularProgressIndicator()
                      : Container(),
                  // : Column(
                  //     children: [
                  //       Icon(
                  //         CupertinoIcons.exclamationmark_circle,
                  //         color: primaryColorLight,
                  //         size: 40,
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.all(16.0),
                  //         child: Text(
                  //           'Looks like you have not finished the account setup. Please complete account setup by taking your picture',
                  //           textAlign: TextAlign.center,
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           Navigator.pushNamed(context,
                  //               CaptureFaceInstructionScreen.routeName);
                  //         },
                  //         child: Container(
                  //           width: 150,
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(8.0),
                  //             color: Colors.orange.withOpacity(0.6),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(12.0),
                  //             child: Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Text('Continue Setup'),
                  //                 Icon(
                  //                   CupertinoIcons.chevron_right,
                  //                   size: 20,
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () async {
                    await authService.handleSignOut();
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  },
                  child: CustomButtonLarge(title: 'Sign Out'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:amazing_app/screens/landing_screen.dart';
import 'package:amazing_app/services/auth_service.dart';
import 'package:amazing_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_button_large.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final ImageProvider<Object> image;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.image});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  AuthService? authService;
  bool isUploading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Display the picture',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () async {
            setState(() {
              isUploading = true;
            });
            await authService?.uploadPic(
                authService!.userUID, widget.imagePath);
            setState(() {
              isUploading = false;
            });
            Navigator.pushNamed(context, LandingScreen.routeName);
          },
          child: isUploading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : CustomButtonLarge(
                  title: 'Upload Picture',
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(widget.imagePath)),
      // body: Container(
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.circular(20.0),
      //     child: Image(height: 150, width: 150, image: widget.imagePath),
      //   ),
      // ),
    );
  }

  Widget createImage(image, VoidCallback onPress) => Material(
          child: InkWell(
        onTap: onPress,
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image(height: 150, width: 150, image: image),
          ),
        ),
      ));
}

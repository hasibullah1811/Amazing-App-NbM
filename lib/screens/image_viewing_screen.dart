import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ImageScreen extends StatelessWidget {
  static const String routeName = "ImageScreen";
  final File imageFile;
  const ImageScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.file(imageFile),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_filereader/flutter_filereader.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OpenFileScreen extends StatefulWidget {
  static const String routeName = "ImageScreen";
  final File file;
  final String mimeType;
  const OpenFileScreen({super.key, required this.file, required this.mimeType});

  @override
  State<OpenFileScreen> createState() => _OpenFileScreenState();
}

class _OpenFileScreenState extends State<OpenFileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Amazing App File Viewer'),
      ),
      body: SafeArea(
          child: (widget.mimeType == 'image/jpeg' ||
                  widget.mimeType == 'image/png' ||
                  widget.mimeType == 'image/gif')
              ? Center(child: Image.file(widget.file))
              : (widget.mimeType == 'application/pdf')
                  ? SfPdfViewer.file(File(
                      widget.file.path,
                    ))
                  : Center(
                      child: Text(
                          'Following filetype is not supported ${widget.mimeType}'))),
    );
  }
}

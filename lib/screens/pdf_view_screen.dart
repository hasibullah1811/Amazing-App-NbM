import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewScreen extends StatefulWidget {
  // final pdfDocument;
  final File pdfFile;
  const PdfViewScreen({super.key, required this.pdfFile});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late PDFDocument pdfDocument;
  bool _isLoading = true;
  loadPdf() async{
    await PDFDocument.fromFile(widget.pdfFile).then((value) {
      setState(() {
        pdfDocument = value;
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() async{
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : PDFViewer(document: pdfDocument)),
    );
  }
}

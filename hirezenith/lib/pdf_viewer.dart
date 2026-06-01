import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerPage extends StatelessWidget {
  final Uint8List? bytes;
  final String name;

  const PDFViewerPage({
    super.key,
    required this.bytes,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
      ),
      body: bytes == null
          ? const Center(child: Text("Failed to load PDF"))
          : SfPdfViewer.memory(bytes!), // ✅ Works on ALL platforms
    );
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hirezenith/ai_service.dart';
import 'package:hirezenith/pdf_viewer.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:hirezenith/resume_feedback.dart';
import 'package:hirezenith/save_feedback.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ResumeDetails extends StatefulWidget {
  final PlatformFile file;
  final String resumeId;

  const ResumeDetails({super.key, required this.file, required this.resumeId});

  @override
  State<StatefulWidget> createState() => _ResumeDetailsState();
}

class _ResumeDetailsState extends State<ResumeDetails> {
  bool isAnalyzing = false;
  Map<String, dynamic>? aiFeedback;

  // This runs ONLY on Web to open PDF in browser tab
  void openPDFWeb(Uint8List bytes, String name) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.window.open(url, "_blank");

    html.Url.revokeObjectUrl(url);
  }

  Widget buildPDFTile() {
    return InkWell(
      onTap: () {
        if (kIsWeb) {
          // On Web → open in browser viewer
          openPDFWeb(widget.file.bytes!, widget.file.name);
        } else {
          // On Android / Windows → use your existing viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerPage(
                bytes: widget.file.bytes,
                name: widget.file.name,
              ),
            ),
          );
        }
      },

      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50), // shadow color
              blurRadius: 12, // how soft the shadow is
              spreadRadius: 5, // how wide the shadow spreads
              offset: Offset(0, 0), // x,y offset 0 = all around
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.file.name,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.open_in_new),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> extractPdfText(Uint8List pdfBytes) async {
    // Load PDF
    PdfDocument document = PdfDocument(inputBytes: pdfBytes);

    // Use PdfTextExtractor
    String allText = PdfTextExtractor(document).extractText();

    document.dispose(); // free memory
    return allText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFd6ccc2),
        centerTitle: true,
        title: Text(
          "Resume Analysis",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// PDF Tile (always visible)
                buildPDFTile(),

                SizedBox(height: 30),

                /// Show button ONLY before analysis
                if (!isAnalyzing && aiFeedback == null)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => isAnalyzing = true); // start loading state

                      // 🔵 Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        /// 1️⃣ Extract text from PDF
                        String text = await extractPdfText(widget.file.bytes!);

                        /// 2️⃣ Send to Ollama AI
                        final analysis = await AIService.analyzeResume(text);

                        /// 3️⃣ Save to Supabase
                        await SupabaseService.saveFeedback(
                          widget.resumeId,
                          widget.file.name,
                          analysis,
                        );

                        /// ❗❗ CLOSE THE LOADING DIALOG
                        Navigator.pop(context);

                        /// 4️⃣ Update state
                        setState(() {
                          aiFeedback = analysis;
                          isAnalyzing = false;
                        });

                        /// 5️⃣ Navigate to feedback page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumeFeedback(analysis: analysis, resumeId: widget.resumeId,),
                          ),
                        );
                      } catch (e) {
                        /// ❗ ALSO CLOSE DIALOG IF ERROR HAPPENS
                        Navigator.pop(context);

                        setState(() => isAnalyzing = false);

                        print("Error analyzing resume: $e");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to analyze resume"),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 50),
                      backgroundColor: const Color.fromARGB(255, 179, 167, 156),
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "Analyze Resume",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

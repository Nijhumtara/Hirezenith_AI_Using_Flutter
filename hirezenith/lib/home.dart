import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hirezenith/resume_review.dart';
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final uuid = Uuid();
  PlatformFile? pickedFile; // store selected file

  Future<void> pickPDF() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true, // ⭐ THIS IS REQUIRED FOR WEB
  );

  if (result != null) {
    final file = result.files.single;
    final resumeId = uuid.v4();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumeDetails(file: file, resumeId: resumeId,),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: BoxDecoration(
            color: const Color(0xFFd5bdaf),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Hirezenith AI",
              style: GoogleFonts.playwriteNgModern(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer (fake)
                  Transform.translate(
                    offset: Offset(0, 8),
                    child: Image.asset(
                      "Asset/Images/resumeAnalysis.png",
                      width: 150,
                      height: 150,
                      color: Colors.black.withOpacity(0.2),
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),

                  // Real image
                  Image.asset(
                    "Asset/Images/resumeAnalysis.png",
                    width: 150,
                    height: 150,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: pickPDF,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 50),
                backgroundColor: const Color(0xFFe6ccb2),
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                "Upload Resume (PDF)",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

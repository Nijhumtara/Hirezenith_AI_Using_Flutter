import 'package:flutter/material.dart';
import 'package:hirezenith/save_feedback.dart';

class ResumeFeedback extends StatefulWidget {
  final Map<String, dynamic> analysis;
  final String resumeId;
  const ResumeFeedback({
    super.key,
    required this.analysis,
    required this.resumeId,
  });

  @override
  State<StatefulWidget> createState() => _ResumeFeedbackState();
}

class _ResumeFeedbackState extends State<ResumeFeedback> {
  List<Map<String, dynamic>> feedbackList = [];
  bool isLoadingFeedback = true;

  @override
  void initState() {
    super.initState();
    loadFeedback();
  }

  Future<void> loadFeedback() async {
    final data = await SupabaseService.fetchFeedback(widget.resumeId);

    setState(() {
      feedbackList = data;
      isLoadingFeedback = false;
    });
  }

  String get scoreText => "${widget.analysis['score'] ?? 0}%";

  String get strengthsText {
    final data = widget.analysis['strengths'];
    if (data == null || data.toString().isEmpty) {
      return "No strengths detected";
    }
    return data is List ? data.join(", ") : data.toString();
  }

  String get weaknessesText {
    final data = widget.analysis['weaknesses'];
    if (data == null || data.toString().isEmpty) {
      return "No weaknesses found";
    }
    return data is List ? data.join(", ") : data.toString();
  }

  String get missingSkillsText {
    final data = widget.analysis['missing_skills'];
    if (data == null || data.toString().isEmpty) {
      return "No missing skills";
    }
    return data is List ? data.join(", ") : data.toString();
  }

  String get suggestionsText {
    final data = widget.analysis['suggestions'];
    if (data == null || data.toString().isEmpty) {
      return "No suggestions";
    }
    return data is List ? data.join(", ") : data.toString();
  }

  Widget _Box({
    required Icon icon,
    required String title,
    required String performance,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(95, 52, 52, 52),
            blurRadius: 5,
            spreadRadius: 6,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 5,),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 121, 109, 81)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            performance,
            style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 121, 109, 81)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(color: const Color(0xFFd5bdaf)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),

              child: Text(
                "Resume Overview",
                style: TextStyle(
                  color: const Color.fromARGB(255, 135, 120, 93),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _Box(
                        icon: Icon(Icons.score, size: 22,color: const Color.fromARGB(255, 121, 109, 81),),
                        title: "Resume Score: ",
                        performance: scoreText,
                      ),
                      SizedBox(height: 10),
                      _Box(
                        icon: Icon(Icons.star, size: 22,color: const Color.fromARGB(255, 121, 109, 81),),
                        title: "Strength: ",
                        performance: strengthsText,
                      ),
                      SizedBox(height: 10),
                      _Box(
                        icon: Icon(Icons.warning, size: 22,color: const Color.fromARGB(255, 121, 109, 81),),
                        title: "Weaknesses: ",
                        performance: weaknessesText,
                      ),
                      SizedBox(height: 10),
                      _Box(
                        icon: Icon(Icons.build, size: 22,color: const Color.fromARGB(255, 121, 109, 81),),
                        title: "Missing Skills: ",
                        performance: missingSkillsText,
                      ),
                      SizedBox(height: 10),
                      _Box(
                        icon: Icon(Icons.lightbulb, size: 22,color: const Color.fromARGB(255, 121, 109, 81),),
                        title: "Suggesions: ",
                        performance: suggestionsText,
                      ),
                      SizedBox(height: 10),
                    ],
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

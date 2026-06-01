import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static Future<Map<String, dynamic>> analyzeResume(String text) async {
    final response = await http.post(
      Uri.parse('http://localhost:11434/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "phi3",
        "prompt": _buildPrompt(text),
        "stream": false
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Ollama error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    String rawText = data['response'];

    // 🔥 Clean + extract JSON safely
    final cleanedJson = _extractAndFixJson(rawText);

    final parsed = jsonDecode(cleanedJson);

    // 🔥 Guarantee no null values
    return {
      "score": parsed["score"] ?? 0,
      "strengths": parsed["strengths"] ?? "No strengths identified.",
      "weaknesses": parsed["weaknesses"] ?? "No weaknesses found.",
      "missing_skills": parsed["missing_skills"] ?? "No missing skills detected.",
      "suggestions": parsed["suggestions"] ?? "No suggestions available.",
    };
  }

  /// ✅ Strong prompt to force structure
  static String _buildPrompt(String text) {
    return """
You are a strict JSON generator.

Return ONLY valid JSON.
No explanation.
No markdown.
No trailing commas.
No comments.

Use this exact schema:

{
  "score": 0-100 integer,
  "strengths": "string",
  "weaknesses": "string",
  "missing_skills": "string",
  "suggestions": "string"
}

If information is missing, write a short default sentence.

Analyze this resume:

$text
""";
  }

  /// ✅ Extract + repair broken JSON from LLM
  static String _extractAndFixJson(String raw) {
    // Remove markdown if model added it
    raw = raw.replaceAll("```json", "").replaceAll("```", "");

    // Find JSON boundaries
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');

    if (start == -1 || end == -1) {
      throw Exception("No JSON found in AI response:\n$raw");
    }

    String jsonString = raw.substring(start, end + 1);

    // 🔥 FIX COMMON LLM JSON ERRORS

    // Remove trailing commas
    jsonString = jsonString.replaceAll(RegExp(r',\s*}'), '}');
    jsonString = jsonString.replaceAll(RegExp(r',\s*]'), ']');

    // Remove invisible control chars
    jsonString = jsonString.replaceAll(RegExp(r'[\x00-\x1F]'), '');

    // Replace smart quotes
    jsonString = jsonString.replaceAll('“', '"').replaceAll('”', '"');

    return jsonString;
  }
}
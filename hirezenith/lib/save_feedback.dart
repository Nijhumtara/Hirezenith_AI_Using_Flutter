import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static String get _userId {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.id;
  }

  static Future<void> saveFeedback(
    String resumeId,
    String fileName,
    Map<String, dynamic> analysis,
  ) async {
    final userId = _userId;
    final existing = await client
        .from('resume_feedback')
        .select('id')
        .eq('user_id', userId)
        .eq('resume_id', resumeId)
        .maybeSingle();

    if (existing != null) return;
    await client.from('resume_feedback').insert({
      'user_id': userId, // 🔥 REQUIRED for RLS
      'resume_id': resumeId,
      'file_name': fileName,

      'score': analysis['score'] ?? 0,
      'strengths': analysis['strengths'] ?? "No strengths detected.",
      'weaknesses': analysis['weaknesses'] ?? "No major weaknesses found.",
      'missing_skills':
          analysis['missing_skills'] ?? "No missing skills identified.",
      'suggestions': analysis['suggestions'] ?? "No additional suggestions.",
    });
  }

  static Future<List<Map<String, dynamic>>> fetchFeedback(
    String resumeId,
  ) async {
    final userId = _userId;

    final response = await client
        .from('resume_feedback')
        .select()
        .eq('user_id', userId) // 🔥 important
        .eq('resume_id', resumeId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

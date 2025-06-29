import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/shared/models/skill_model.dart';

class SkillRepository {
  final _supabase = Supabase.instance.client;
  // Assuming 'skills' is the correct table name. Not found in migrations or SupabaseConfig.
  static const String _skillsTable = 'skills';

  // Singleton pattern
  static final SkillRepository _instance = SkillRepository._internal();
  factory SkillRepository() => _instance;
  SkillRepository._internal();

  Future<List<SkillModel>> getUserSkills(String userId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_skillsTable)
          .select('id, user_id, name, endorsement_count, endorsedByUserIds')
          .eq('user_id', userId)
          .order('endorsement_count', ascending: false);
      
      // Errors will be caught by the try-catch block.
      return data.map((json) => SkillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user skills: $e');
    }
  }

  Future<void> addSkill(String userId, String skillName) async {
    try {
      await _supabase.from(_skillsTable).insert({
        'user_id': userId, // DB uses user_id
        'name': skillName,
        'endorsement_count': 0,
        'endorsedByUserIds': [],
        // 'created_at': DateTime.now().toIso8601String(), // Assuming a created_at column
      });
      // Errors will be caught by the try-catch block.
    } catch (e) {
      throw Exception('Failed to add skill: $e');
    }
  }

  Future<void> endorseSkill(String skillId, String endorsedByUserId) async {
    try {
      // TODO: This operation (read then write) is prone to race conditions.
      // Consider implementing as a Supabase RPC function for transactional integrity.
      // .single() will throw an error if no record or multiple records are found.
      // If it completes without error, skill is guaranteed to be non-null.
      final Map<String, dynamic> skill = await _supabase
          .from(_skillsTable)
          .select('id, user_id, name, endorsement_count, endorsedByUserIds') // Alias user_id to userId for SkillModel
          .eq('id', skillId)
          .single();

      // Removed skill == null check as .single() would throw if no record.
      
      // 'userId' in skill map is the skill owner's ID, aliased from 'user_id'
      if (skill['userId'] == endorsedByUserId) {
        throw Exception('Cannot endorse own skills');
      }

      List<String> endorsedByUserIdsList = List<String>.from(skill['endorsedByUserIds'] ?? []);
      if (endorsedByUserIdsList.contains(endorsedByUserId)) {
        throw Exception('Already endorsed this skill');
      }

      final updatedEndorsedUserIds = [...endorsedByUserIdsList, endorsedByUserId];
      final newEndorsementCount = (skill['endorsement_count'] as int? ?? 0) + 1;

      await _supabase
          .from(_skillsTable)
          .update({
            'endorsement_count': newEndorsementCount,
            'endorsedByUserIds': updatedEndorsedUserIds,
          })
          .eq('id', skillId);
      // Errors will be caught by the try-catch block.
    } catch (e) {
      throw Exception('Failed to endorse skill: $e');
    }
  }

  Future<List<SkillModel>> getTopSkills(String userId, {int limit = 3}) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_skillsTable)
          .select('id, user_id, name, endorsement_count, endorsedByUserIds')
          .eq('user_id', userId) // DB uses user_id
          .order('endorsement_count', ascending: false)
          .limit(limit);
      
      // Errors will be caught by the try-catch block.
      return data.map((json) => SkillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch top skills: $e');
    }
  }
}
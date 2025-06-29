class SkillModel {
  final String id;
  final String userId;
  final String name;
  // ignore: non_constant_identifier_names
  final int endorsement_count;
  final List<String> endorsedByUserIds;

  SkillModel({
    required this.id,
    required this.userId,
    required this.name,
    // ignore: non_constant_identifier_names
    this.endorsement_count = 0,
    this.endorsedByUserIds = const [],
  });

  // TODO: Firebase Integration
  // - Store skills in Firebase Firestore
  // - Use Cloud Functions to handle endorsement counts
  // - Add security rules to prevent self-endorsement

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    // TODO: Investigate the 'skills' table schema. 'id', 'userId', and 'name' should ideally be non-nullable in the database.
    // Providing default empty strings here to prevent TypeErrors if data is unexpectedly null.
    return SkillModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      endorsement_count: json['endorsement_count'] as int? ?? 0, // Also ensure endorsementCount is handled if null
      endorsedByUserIds: List<String>.from(json['endorsedByUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'endorsement_count': endorsement_count,
      'endorsedByUserIds': endorsedByUserIds,
    };
  }
}
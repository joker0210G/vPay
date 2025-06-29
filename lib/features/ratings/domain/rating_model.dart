class RatingModel {
  final String id;
  final String taskId; // Renamed task_id to taskId
  final String fromUserId;
  final String toUserId;
  final int score; // 1-5 stars
  final String feedback;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.taskId, // Renamed task_id to taskId
    required this.fromUserId,
    required this.toUserId,
    required this.score,
    required this.feedback,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
        id: json['id'],
        taskId: json['task_id'], // Reads 'task_id' from JSON, assigns to taskId
        fromUserId: json['from_user_id'],
        toUserId: json['to_user_id'],
        score: json['score'],
        feedback: json['feedback'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId, // Writes taskId to 'task_id' in JSON
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'score': score,
        'feedback': feedback,
        'created_at': createdAt.toIso8601String(),
      };
}

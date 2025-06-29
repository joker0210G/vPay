class TestimonialModel {
  final String id;
  final String taskId;
  final String fromUserId;
  final String toUserId;
  final String comment;
  final double rating;  // 1-5 stars
  final DateTime createdAt;

  TestimonialModel({
    required this.id,
    required this.taskId,
    required this.fromUserId,
    required this.toUserId,
    required this.comment,
    required double rating,
    required this.createdAt,
  }) : rating = rating.clamp(1.0, 5.0);  // Ensure rating stays within 1-5 range

  /// Creates a copy of this TestimonialModel with the given fields updated
  TestimonialModel copyWith({
    String? id,
    String? taskId,
    String? fromUserId,
    String? toUserId,
    String? comment,
    double? rating,
    DateTime? createdAt,
  }) {
    return TestimonialModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a TestimonialModel from JSON
  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    // TODO: Investigate the 'testimonials' table schema. Fields like 'id', 'task_id', 
    // 'fromUserId', 'toUserId', 'comment', 'rating', 'createdAt' should ideally be 
    // non-nullable in the database and correctly formatted.
    // Providing defaults here to prevent TypeErrors/FormatExceptions if data is unexpectedly null or malformed.
    return TestimonialModel(
      id: json['id'] as String? ?? '',
      taskId: json['task_id'] as String? ?? '',
      fromUserId: json['fromUserId'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 1.0, // Default to 1.0 (within clamp range)
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0), // Default to Epoch
    );
  }

  /// Converts this TestimonialModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

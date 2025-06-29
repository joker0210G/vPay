import 'package:vpay/features/task/domain/task_status.dart';
import 'package:flutter/material.dart';

extension TaskCategoryIconExtension on TaskCategory {
  IconData get icon {
    switch (this) {
      case TaskCategory.academicSupport:
        return Icons.school;
      case TaskCategory.campusErrands:
        return Icons.directions_walk;
      case TaskCategory.techHelp:
        return Icons.computer;
      case TaskCategory.eventSupport:
        return Icons.event;
      case TaskCategory.other:
        return Icons.category;
    }
  }
}

// Optional: Enum for category
enum TaskCategory { academicSupport, campusErrands, techHelp, eventSupport, other }

extension TaskCategoryDisplay on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.academicSupport:
        return 'Academic Support';
      case TaskCategory.campusErrands:
        return 'Campus Errands';
      case TaskCategory.techHelp:
        return 'Tech Help';
      case TaskCategory.eventSupport:
        return 'Event Support';
      case TaskCategory.other:
        return 'Other';
    }
  }
}

// For JSON (de)serialization
extension TaskCategoryJson on TaskCategory {
  String toJson() => toString().split('.').last;

  static TaskCategory fromJson(String value) {
    return TaskCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TaskCategory.other,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String? assigneeId;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final TaskStatus status;
  final TaskCategory category;
  List<String> tags;
  final double? latitude;
  final double? longitude;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    this.assigneeId,
    required this.amount,
    this.currency = 'USD',
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    required this.status,
    required this.category,
    List<String>? tags,
    this.latitude,
    this.longitude,
  }) : tags = tags ?? [] {
    _validateInputs();
  }

  void _validateInputs() {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (amount < 0) {
      throw ArgumentError('Amount must be non-negative');
    }
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? assigneeId,
    double? amount,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    TaskStatus? status,
    TaskCategory? category,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      assigneeId: assigneeId ?? this.assigneeId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      creatorId: json['creator_id'],
      assigneeId: json['assignee_id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      category: TaskCategoryJson.fromJson(json['category'] ?? 'other'),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creator_id': creatorId,
      'assignee_id': assigneeId,
      'amount': amount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'category': category.toJson(),
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TaskModel(id: $id, title: $title, status: $status)';

  // Tag management methods
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }
}

// core/constants/colors.dart
import 'package:flutter/material.dart';
import 'package:vpay/features/task/domain/task_status.dart';

class AppColors {
  static const Color primary = Color(0xFF001C3C);
  static const Color secondary = Color(0xFF50EDFE);
  static const Color accent = Color(0xFFFF8A65);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color background = Color(0xFFF8F9FA);
}

/// Task status color mapping
class TaskStatusColors {
  static const pending = Color(0xFFFFE082);        // Light Orange
  static const inProgress = Color(0xFF90CAF9);     // Light Blue
  static const awaitingReview = Color(0xFFE1BEE7); // Light Purple
  static const paymentDue = Color(0xFFFFECB3);     // Light Amber
  static const completed = Color(0xFFA5D6A7);      // Light Green
  static const disputed = Color(0xFFFFAB91);       // Light Deep Orange
  static const cancelled = Color(0xFFEF9A9A);      // Light Red
}

/// Extension for TaskStatus to get its color
extension TaskStatusColorExtension on TaskStatus {
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return TaskStatusColors.pending;
      case TaskStatus.inProgress:
        return TaskStatusColors.inProgress;
      case TaskStatus.awaitingReview:
        return TaskStatusColors.awaitingReview;
      case TaskStatus.paymentDue:
        return TaskStatusColors.paymentDue;
      case TaskStatus.completed:
        return TaskStatusColors.completed;
      case TaskStatus.disputed:
        return TaskStatusColors.disputed;
      case TaskStatus.cancelled:
        return TaskStatusColors.cancelled;
    }
  }
}
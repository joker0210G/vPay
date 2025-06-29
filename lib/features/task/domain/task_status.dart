import 'package:flutter/material.dart';

enum TaskStatus {
  pending,
  inProgress,
  awaitingReview,
  paymentDue,
  completed,
  disputed,
  cancelled;

  String toJson() => name;

  static TaskStatus fromJson(String json) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => TaskStatus.pending,
    );
  }
}

// Extension for status colors
extension TaskStatusColor on TaskStatus {
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.awaitingReview:
        return Colors.orange;
      case TaskStatus.paymentDue:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.disputed:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.black54;
    }
  }
}

// Extension for user-friendly display names
extension TaskStatusDisplay on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.awaitingReview:
        return 'Awaiting Review';
      case TaskStatus.paymentDue:
        return 'Payment Due';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.disputed:
        return 'Disputed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}

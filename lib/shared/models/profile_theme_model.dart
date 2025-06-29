import 'package:flutter/material.dart';

class ProfileTheme {
  final String id;
  final String name;
  final String description;
  final ThemeData theme;
  final String requirement;
  final bool isUnlocked;

  const ProfileTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.requirement,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'requirement': requirement,
    'isUnlocked': isUnlocked,
  };

  factory ProfileTheme.fromJson(Map<String, dynamic> json, ThemeData theme) {
    return ProfileTheme(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      requirement: json['requirement'],
      isUnlocked: json['isUnlocked'] ?? false,
      theme: theme,
    );
  }
}
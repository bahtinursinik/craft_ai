import 'dart:convert';

class AiModel {

  AiModel({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.steps,
    required this.calories,
  });

  factory AiModel.fromRawJson(String str) =>
      AiModel.fromJson(json.decode(str) as Map<String, dynamic>);

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      title: (json['title'] as String?) ?? 'Untitled Plan',

      description: (json['description'] as String?) ?? 'No description.',
      difficulty: (json['difficulty'] as String?) ?? 'Unknown',

      duration: json['duration']?.toString() ?? '15',

      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      calories: json['calories']?.toString() ?? '0',
    );
  }
  final String title;
  final String description;
  final String difficulty;
  final String duration;
  final List<String> steps;
  final String calories;
}

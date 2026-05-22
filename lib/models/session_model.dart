import 'question_model.dart';
import 'evaluation_model.dart';

class SessionModel {
  final String id;
  final String jobDescription;
  final DateTime createdAt;
  final List<QuestionModel> questions;
  final List<EvaluationModel> evaluations;
  final double? overallScore;
  final bool isCompleted;

  SessionModel({
    required this.id,
    required this.jobDescription,
    required this.createdAt,
    this.questions = const [],
    this.evaluations = const [],
    this.overallScore,
    this.isCompleted = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    var questionsList = (json['questions'] as List?)
            ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    var evaluationsList = (json['evaluations'] as List?)
            ?.map((e) => EvaluationModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    DateTime parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.parse(json['created_at'] as String);
    } else if (json['createdAt'] != null) {
      parsedDate = DateTime.parse(json['createdAt'] as String);
    } else {
      parsedDate = DateTime.now();
    }

    return SessionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      jobDescription: json['job_description'] as String? ?? json['jobDescription'] as String? ?? '',
      createdAt: parsedDate.toLocal(),
      questions: questionsList,
      evaluations: evaluationsList,
      overallScore: json['overall_score'] != null ? (json['overall_score'] as num).toDouble() : null,
      isCompleted: json['is_completed'] as bool? ?? json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_description': jobDescription,
      'created_at': createdAt.toUtc().toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'evaluations': evaluations.map((e) => e.toJson()).toList(),
      'overall_score': overallScore,
      'is_completed': isCompleted,
    };
  }
}

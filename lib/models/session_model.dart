import 'question_model.dart';
import 'evaluation_model.dart';

class SessionModel {
  final String id;
  final String jobTitle;
  final String jobDescription;
  final DateTime createdAt;
  final List<QuestionModel> questions;
  final List<EvaluationModel> evaluations;
  final double? overallScore;
  final bool isCompleted;

  SessionModel({
    required this.id,
    required this.jobTitle,
    required this.jobDescription,
    required this.createdAt,
    this.questions = const [],
    this.evaluations = const [],
    this.overallScore,
    this.isCompleted = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    // 1. Unwrap the nested "session" object if present
    final Map<String, dynamic> sessionData = json['session'] is Map<String, dynamic>
        ? json['session'] as Map<String, dynamic>
        : json;

    // 2. Parse questions (can be in root json or inside sessionData)
    var questionsListJson = json['questions'] ?? sessionData['questions'];
    var questionsList = (questionsListJson as List?)
            ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    // 3. Parse evaluations (can be in root json or inside sessionData)
    var evaluationsListJson = json['evaluations'] ?? sessionData['evaluations'];
    var evaluationsList = (evaluationsListJson as List?)
            ?.map((e) => EvaluationModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // 4. Extract evaluations from questions list items if evaluations list is empty
    if (evaluationsList.isEmpty && questionsListJson is List) {
      for (final qJson in questionsListJson) {
        if (qJson is Map<String, dynamic>) {
          final hasScore = qJson['ai_score'] != null || qJson['aiScore'] != null;
          final hasFeedback = qJson['ai_feedback'] != null || qJson['aiFeedback'] != null;
          final hasUserAnswer = qJson['user_answer'] != null || qJson['userAnswer'] != null;
          
          if (hasScore || hasFeedback || hasUserAnswer) {
            final evalMap = Map<String, dynamic>.from(qJson);
            evalMap['questionId'] = qJson['id'] ?? qJson['_id'];
            evaluationsList.add(EvaluationModel.fromJson(evalMap));
          }
        }
      }
    }

    DateTime parsedDate;
    if (sessionData['created_at'] != null) {
      parsedDate = DateTime.parse(sessionData['created_at'] as String);
    } else if (sessionData['createdAt'] != null) {
      parsedDate = DateTime.parse(sessionData['createdAt'] as String);
    } else {
      parsedDate = DateTime.now();
    }

    String description = sessionData['job_description'] as String? ?? sessionData['jobDescription'] as String? ?? '';
    
    String title = sessionData['jobTitle'] as String? ?? sessionData['job_title'] as String? ?? '';
    if (title.isEmpty) {
      final lines = description.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
      if (lines.isNotEmpty) {
        title = lines.first;
        if (title.length > 100) {
          title = title.substring(0, 100);
        }
      } else {
        title = 'Mock Interview';
      }
    }

    return SessionModel(
      id: sessionData['id'] as String? ?? sessionData['_id'] as String? ?? sessionData['sessionId'] as String? ?? '',
      jobTitle: title,
      jobDescription: description,
      createdAt: parsedDate.toLocal(),
      questions: questionsList,
      evaluations: evaluationsList,
      overallScore: sessionData['overall_score'] != null 
          ? (sessionData['overall_score'] as num).toDouble() 
          : (sessionData['overallScore'] != null ? (sessionData['overallScore'] as num).toDouble() : null),
      isCompleted: sessionData['is_completed'] as bool? ?? sessionData['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'created_at': createdAt.toUtc().toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'evaluations': evaluations.map((e) => e.toJson()).toList(),
      'overall_score': overallScore,
      'is_completed': isCompleted,
    };
  }
}

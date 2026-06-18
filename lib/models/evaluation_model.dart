class EvaluationModel {
  final String questionId;
  final int score; // 1-10
  final String feedback;
  final String modelAnswer;
  final String userAnswer;

  EvaluationModel({
    required this.questionId,
    required this.score,
    required this.feedback,
    required this.modelAnswer,
    required this.userAnswer,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      questionId: json['questionId'] as String? ?? json['question_id'] as String? ?? '',
      score: (json['aiScore'] as num? ?? json['ai_score'] as num? ?? json['score'] as num? ?? 0).toInt(),
      feedback: json['aiFeedback'] as String? ?? json['ai_feedback'] as String? ?? json['feedback'] as String? ?? '',
      modelAnswer: json['betterAnswer'] as String? ?? json['better_answer'] as String? ?? json['modelAnswer'] as String? ?? json['model_answer'] as String? ?? json['suggested_answer'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? json['user_answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'score': score,
      'feedback': feedback,
      'model_answer': modelAnswer,
      'user_answer': userAnswer,
    };
  }
}

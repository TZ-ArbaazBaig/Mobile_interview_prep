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
      questionId: json['question_id'] as String? ?? '',
      score: (json['score'] as num? ?? 0).toInt(),
      feedback: json['feedback'] as String? ?? '',
      modelAnswer: json['model_answer'] as String? ?? json['suggested_answer'] as String? ?? '',
      userAnswer: json['user_answer'] as String? ?? '',
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

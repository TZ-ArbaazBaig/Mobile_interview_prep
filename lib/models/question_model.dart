class QuestionModel {
  final String id;
  final String text;
  final String category;
  final String difficulty;
  final String hint;
  final int orderIndex;

  QuestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
    required this.hint,
    required this.orderIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      text: json['text'] as String? ?? json['question'] as String? ?? json['questionText'] as String? ?? json['question_text'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'medium',
      hint: json['hint'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num? ?? json['order_index'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'difficulty': difficulty,
      'hint': hint,
      'orderIndex': orderIndex,
    };
  }
}

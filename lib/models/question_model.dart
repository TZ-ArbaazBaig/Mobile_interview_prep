class QuestionModel {
  final String id;
  final String text;
  final String category;

  QuestionModel({
    required this.id,
    required this.text,
    required this.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      text: json['text'] as String? ?? json['question'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
    };
  }
}

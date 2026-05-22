class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',  // Android emulator localhost
  );

  // Auth / User
  static const String syncUser       = '/auth/sync';

  // Sessions
  static const String sessions       = '/sessions';
  static String sessionById(String id) => '/sessions/$id';

  // Interview
  static String generateQuestions(String sessionId) => '/sessions/$sessionId/questions';
  static String submitAnswer(String sessionId, String questionId) =>
      '/sessions/$sessionId/questions/$questionId/answer';

  // Results
  static String sessionResults(String sessionId) => '/sessions/$sessionId/results';
}

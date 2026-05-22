import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_interview_prep/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('Email Validator - Valid Email', () {
      final result = Validators.validateEmail('candidate@interviewprep.ai');
      expect(result, isNull);
    });

    test('Email Validator - Invalid Email', () {
      final result = Validators.validateEmail('invalid-email');
      expect(result, isNotNull);
    });

    test('Required Validator - Empty Value', () {
      final result = Validators.validateRequired('', 'Job Description');
      expect(result, isNotNull);
    });
  });
}

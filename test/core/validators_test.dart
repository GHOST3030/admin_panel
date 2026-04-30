import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null', () => expect(Validators.required(null), isNotNull));
    test('returns error for empty string', () => expect(Validators.required(''), isNotNull));
    test('returns error for whitespace', () => expect(Validators.required('  '), isNotNull));
    test('returns null for valid value', () => expect(Validators.required('hello'), isNull));
  });

  group('Validators.email', () {
    test('rejects invalid email', () => expect(Validators.email('not-an-email'), isNotNull));
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('accepts valid email', () => expect(Validators.email('admin@test.com'), isNull));
  });

  group('Validators.slug', () {
    test('accepts valid slug', () => expect(Validators.slug('mens-clothing'), isNull));
    test('rejects uppercase', () => expect(Validators.slug('Mens'), isNotNull));
    test('rejects spaces', () => expect(Validators.slug('mens clothing'), isNotNull));
  });

  group('Validators.hexColor', () {
    test('accepts valid hex', () => expect(Validators.hexColor('#FF5733'), isNull));
    test('accepts null (optional)', () => expect(Validators.hexColor(null), isNull));
    test('rejects invalid format', () => expect(Validators.hexColor('red'), isNotNull));
  });

  group('Validators.positiveNumber', () {
    test('accepts positive', () => expect(Validators.positiveNumber('9.99'), isNull));
    test('accepts zero', () => expect(Validators.positiveNumber('0'), isNull));
    test('rejects negative', () => expect(Validators.positiveNumber('-1'), isNotNull));
    test('rejects non-numeric', () => expect(Validators.positiveNumber('abc'), isNotNull));
  });
}

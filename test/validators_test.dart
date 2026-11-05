import 'package:flutter_test/flutter_test.dart';

import 'package:dkmp/core/validators/validators.dart';

void main() {
  group('Validators.phone', () {
    test('accepts valid mainland mobile numbers', () {
      expect(Validators.phone('13812345678'), isNull);
      expect(Validators.phone(' 19912345678 '), isNull);
    });

    test('rejects empty or malformed numbers', () {
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('12345678901'), isNotNull);
      expect(Validators.phone('12812345678'), isNotNull);
      expect(Validators.phone('1381234567'), isNotNull);
      expect(Validators.phone('138123456789'), isNotNull);
      expect(Validators.phone('abc'), isNotNull);
    });
  });

  group('Validators.captchaCode', () {
    test('accepts 4~8 characters', () {
      expect(Validators.captchaCode('ab12'), isNull);
      expect(Validators.captchaCode(' abcd12 '), isNull);
    });

    test('rejects empty or out-of-range length', () {
      expect(Validators.captchaCode(null), isNotNull);
      expect(Validators.captchaCode(''), isNotNull);
      expect(Validators.captchaCode('ab1'), isNotNull);
      expect(Validators.captchaCode('abcd12345'), isNotNull);
    });
  });

  group('Validators.smsCode', () {
    test('accepts 6 digits', () {
      expect(Validators.smsCode('123456'), isNull);
      expect(Validators.smsCode(' 123456 '), isNull);
    });

    test('rejects non-6-digit input', () {
      expect(Validators.smsCode(null), isNotNull);
      expect(Validators.smsCode(''), isNotNull);
      expect(Validators.smsCode('12345'), isNotNull);
      expect(Validators.smsCode('1234567'), isNotNull);
      expect(Validators.smsCode('12 456'), isNotNull);
      expect(Validators.smsCode('abcdef'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('accepts 6~20 characters', () {
      expect(Validators.password('a12345'), isNull);
      expect(Validators.password('a' * 20), isNull);
    });

    test('rejects empty or out-of-range length', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('a1234'), isNotNull);
      expect(Validators.password('a' * 21), isNotNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('passes when values match', () {
      expect(Validators.confirmPassword('a12345', 'a12345'), isNull);
    });

    test('fails on mismatch or empty', () {
      expect(Validators.confirmPassword('a12345', 'a12346'), isNotNull);
      expect(Validators.confirmPassword(null, 'a12345'), isNotNull);
      expect(Validators.confirmPassword('', 'a12345'), isNotNull);
    });
  });
}

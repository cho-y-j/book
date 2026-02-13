import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('빈 값이면 에러 메시지', () {
        expect(Validators.validateEmail(''), '이메일을 입력해주세요');
        expect(Validators.validateEmail(null), '이메일을 입력해주세요');
      });

      test('잘못된 형식이면 에러 메시지', () {
        expect(Validators.validateEmail('test'), '올바른 이메일 형식이 아닙니다');
        expect(Validators.validateEmail('test@'), '올바른 이메일 형식이 아닙니다');
      });

      test('올바른 이메일이면 null', () {
        expect(Validators.validateEmail('test@example.com'), null);
      });
    });

    group('validatePassword', () {
      test('빈 값이면 에러 메시지', () {
        expect(Validators.validatePassword(''), '비밀번호를 입력해주세요');
      });

      test('8자 미만이면 에러 메시지', () {
        expect(Validators.validatePassword('1234567'), '비밀번호는 8자 이상이어야 합니다');
      });

      test('8자 이상이면 null', () {
        expect(Validators.validatePassword('12345678'), null);
      });
    });

    group('validateNickname', () {
      test('빈 값이면 에러 메시지', () {
        expect(Validators.validateNickname(''), '닉네임을 입력해주세요');
      });

      test('2자 미만이면 에러 메시지', () {
        expect(Validators.validateNickname('가'), '닉네임은 2~12자여야 합니다');
      });

      test('12자 초과면 에러 메시지', () {
        expect(Validators.validateNickname('가나다라마바사아자차카타파'), '닉네임은 2~12자여야 합니다');
      });

      test('특수문자 포함이면 에러 메시지', () {
        expect(Validators.validateNickname('닉네임!'), '한글, 영문, 숫자, 밑줄만 사용 가능합니다');
      });

      test('올바른 닉네임이면 null', () {
        expect(Validators.validateNickname('책다리유저'), null);
        expect(Validators.validateNickname('bookUser_1'), null);
      });
    });

    group('isValidIsbn', () {
      test('ISBN-10 유효', () {
        expect(Validators.isValidIsbn('1234567890'), true);
      });

      test('ISBN-13 유효', () {
        expect(Validators.isValidIsbn('9781234567890'), true);
      });

      test('하이픈 포함 ISBN-13 유효', () {
        expect(Validators.isValidIsbn('978-1-234-56789-0'), true);
      });

      test('잘못된 길이 무효', () {
        expect(Validators.isValidIsbn('12345'), false);
      });
    });

    group('validateBookTitle', () {
      test('빈 값이면 에러 메시지', () {
        expect(Validators.validateBookTitle(''), '책 제목을 입력해주세요');
      });

      test('올바른 제목이면 null', () {
        expect(Validators.validateBookTitle('어린왕자'), null);
      });
    });
  });
}

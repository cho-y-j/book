class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return '이메일을 입력해주세요';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식이 아닙니다';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
    if (value.length < 8) return '비밀번호는 8자 이상이어야 합니다';
    return null;
  }

  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) return '닉네임을 입력해주세요';
    if (value.length < 2 || value.length > 12) return '닉네임은 2~12자여야 합니다';
    final nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9_]+$');
    if (!nicknameRegex.hasMatch(value)) return '한글, 영문, 숫자, 밑줄만 사용 가능합니다';
    return null;
  }

  static String? validateBookTitle(String? value) {
    if (value == null || value.isEmpty) return '책 제목을 입력해주세요';
    if (value.length > 200) return '제목은 200자 이내로 입력해주세요';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName을(를) 입력해주세요';
    return null;
  }

  static bool isValidIsbn(String isbn) {
    final cleaned = isbn.replaceAll('-', '');
    return cleaned.length == 10 || cleaned.length == 13;
  }
}

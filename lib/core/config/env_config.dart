/// Environment configuration
/// Set values via --dart-define or .env file
class EnvConfig {
  EnvConfig._();

  static const aladinApiKey = String.fromEnvironment('ALADIN_API_KEY');
  static const naverClientId = String.fromEnvironment('NAVER_CLIENT_ID');
  static const naverClientSecret = String.fromEnvironment('NAVER_CLIENT_SECRET');
  static const kakaoRestApiKey = String.fromEnvironment('KAKAO_REST_API_KEY');
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const deepSeekApiKey = String.fromEnvironment('DEEPSEEK_API_KEY');

  static bool get isProduction => const String.fromEnvironment('ENV') == 'prod';
  static bool get isDevelopment => !isProduction;
}

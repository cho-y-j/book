import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _autoLogin = true;
  String? _error;
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadAutoLoginPref();
  }

  Future<void> _loadAutoLoginPref() async {
    await _storage.init();
    if (mounted) {
      setState(() => _autoLogin = _storage.autoLogin);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authStateProvider, (prev, next) {
      if (next.value != null) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.menu_book_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('책다리', style: AppTypography.headlineLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('책으로 연결되는 다리', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 48),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(hintText: '이메일', prefixIcon: Icon(Icons.email_outlined)),
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(hintText: '비밀번호', prefixIcon: Icon(Icons.lock_outlined)),
                    validator: Validators.validatePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),

                  // 자동 로그인 체크박스
                  Row(children: [
                    SizedBox(
                      height: 24, width: 24,
                      child: Checkbox(
                        value: _autoLogin,
                        onChanged: (v) async {
                          setState(() => _autoLogin = v ?? true);
                          await _storage.setAutoLogin(_autoLogin);
                        },
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        setState(() => _autoLogin = !_autoLogin);
                        await _storage.setAutoLogin(_autoLogin);
                      },
                      child: Text('자동 로그인', style: AppTypography.bodySmall),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text('비밀번호 찾기', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('로그인'),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.divider)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('또는', style: AppTypography.bodySmall)),
                const Expanded(child: Divider(color: AppColors.divider)),
              ]),
              const SizedBox(height: 24),
              _SocialLoginButton(icon: Icons.chat_bubble, label: '카카오로 시작하기', color: const Color(0xFFFEE500), textColor: Colors.black87, onPressed: () { /* TODO: Kakao OAuth */ }),
              const SizedBox(height: 12),
              _SocialLoginButton(icon: Icons.g_mobiledata, label: 'Google로 시작하기', color: Colors.white, textColor: Colors.black87, onPressed: () { /* TODO: Google Sign-In */ }),
              const SizedBox(height: 12),
              _SocialLoginButton(icon: Icons.apple, label: 'Apple로 시작하기', color: Colors.black, textColor: Colors.white, onPressed: () { /* TODO: Apple Sign-In */ }),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.push(AppRoutes.signup),
                child: Text('계정이 없으신가요? 회원가입', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      // 자동 로그인 설정 저장
      await _storage.setAutoLogin(_autoLogin);

      final authRepo = ref.read(authRepositoryProvider);
      final credential = await authRepo.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 기존 유저 중 Firestore 프로필이 없는 경우 자동 생성
      final uid = credential.user!.uid;
      final userRepo = ref.read(userRepositoryProvider);
      final existingProfile = await userRepo.getUser(uid);
      if (existingProfile == null) {
        final now = DateTime.now();
        await userRepo.createUser(UserModel(
          uid: uid,
          nickname: credential.user!.email?.split('@').first ?? '사용자',
          email: credential.user!.email ?? '',
          primaryLocation: '',
          geoPoint: const GeoPoint(0, 0),
          bookTemperature: 36.5,
          totalExchanges: 0,
          points: 0,
          createdAt: now,
          lastActiveAt: now,
        ));
      }

      // Navigation handled by authStateProvider listener above
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = _getErrorMessage(e);
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = '이메일을 먼저 입력해주세요');
      return;
    }
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호 재설정 이메일을 보냈습니다')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = _getErrorMessage(e));
    }
  }

  String _getErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return '존재하지 않는 계정입니다';
    if (msg.contains('wrong-password')) return '비밀번호가 틀렸습니다';
    if (msg.contains('invalid-email')) return '유효하지 않은 이메일입니다';
    if (msg.contains('too-many-requests')) return '너무 많은 시도입니다. 잠시 후 다시 시도하세요';
    if (msg.contains('INVALID_LOGIN_CREDENTIALS')) return '이메일 또는 비밀번호가 틀렸습니다';
    return '로그인에 실패했습니다. 다시 시도해주세요';
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final Color textColor; final VoidCallback onPressed;
  const _SocialLoginButton({required this.icon, required this.label, required this.color, required this.textColor, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
      onPressed: onPressed, icon: Icon(icon, color: textColor), label: Text(label, style: TextStyle(color: textColor)),
      style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), side: const BorderSide(color: AppColors.divider))),
    ));
  }
}

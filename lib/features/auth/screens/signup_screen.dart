import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); _nicknameController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (prev, next) {
      if (next.value != null) context.go(AppRoutes.home);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_error != null) ...[
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
            const SizedBox(height: 16),
          ],
          TextFormField(controller: _nicknameController, decoration: const InputDecoration(hintText: '닉네임', prefixIcon: Icon(Icons.person_outline)), validator: Validators.validateNickname),
          const SizedBox(height: 16),
          TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: '이메일', prefixIcon: Icon(Icons.email_outlined)), validator: Validators.validateEmail, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          TextFormField(controller: _passwordController, decoration: const InputDecoration(hintText: '비밀번호 (8자 이상)', prefixIcon: Icon(Icons.lock_outlined)), validator: Validators.validatePassword, obscureText: true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignup,
            child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('가입하기'),
          ),
        ])),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signUpWithEmail(_emailController.text.trim(), _passwordController.text);
      // After signup, create user profile in Firestore
      // Navigation handled by authStateProvider listener
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString().contains('email-already-in-use') ? '이미 사용중인 이메일입니다' : '회원가입에 실패했습니다'; });
    }
  }
}

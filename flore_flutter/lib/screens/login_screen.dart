import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;

  const LoginScreen({super.key, this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final _authService = widget.authService ?? AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Senha',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 10),
                _buildForgotPassword(),
                const SizedBox(height: 28),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSignupLink(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.yard_outlined, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 14),
        const Text(
          'Florê',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.tealDark,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'CLOSET CIRCULAR',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.orange,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vinda de volta',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.dark),
        ),
        SizedBox(height: 4),
        Text(
          'Entre na sua conta para continuar',
          style: TextStyle(fontSize: 14, color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        ),
        child: const Text(
          'Esqueci minha senha',
          style: TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _login,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.border)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('ou', style: TextStyle(color: AppColors.gray, fontSize: 12)),
      ),
      const Expanded(child: Divider(color: AppColors.border)),
    ]);
  }

  Widget _buildSignupLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Não tem uma conta? ', style: TextStyle(color: AppColors.gray, fontSize: 13)),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
        child: const Text('Cadastre-se', style: TextStyle(color: AppColors.teal, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

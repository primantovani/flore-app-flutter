import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  final AuthService? authService;

  const SignupScreen({super.key, this.authService});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final _authService = widget.authService ?? AuthService();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível criar sua conta. Tente novamente.');
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.tealDark, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildTitle(),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Nome completo',
                  hint: 'Priscila Mantovani',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: Validators.name,
                ),
                const SizedBox(height: 14),
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
                  hint: 'Mínimo 6 caracteres',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 8),
                _buildTerms(),
                const SizedBox(height: 28),
                _buildSignupButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Criar conta',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.dark),
        ),
        SizedBox(height: 4),
        Text(
          'Faça parte da moda circular',
          style: TextStyle(fontSize: 14, color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return Row(children: [
      const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 12, color: AppColors.gray),
            children: [
              TextSpan(text: 'Concordo com os '),
              TextSpan(text: 'Termos de Uso', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
              TextSpan(text: ' e '),
              TextSpan(text: 'Política de Privacidade', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _signup,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Criar minha conta', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Já tem uma conta? ', style: TextStyle(color: AppColors.gray, fontSize: 13)),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text('Entrar', style: TextStyle(color: AppColors.teal, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

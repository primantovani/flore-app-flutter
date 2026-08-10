import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AuthService? authService;

  const ForgotPasswordScreen({super.key, this.authService});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final _authService = widget.authService ?? AuthService();
  bool _isLoading = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await _authService.requestPasswordReset(email: _emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível enviar o e-mail. Tente novamente.');
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _sent ? _buildConfirmation() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Esqueci minha senha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.dark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Informe seu e-mail e enviaremos instruções para redefinir sua senha',
            style: TextStyle(fontSize: 14, color: AppColors.gray),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'E-mail',
            hint: 'seu@email.com',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isLoading ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Enviar instruções', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(color: AppColors.tealSurface, shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.teal, size: 32),
        ),
        const SizedBox(height: 20),
        const Text(
          'E-mail enviado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark),
        ),
        const SizedBox(height: 8),
        Text(
          'Se ${_emailController.text.trim()} estiver cadastrado, você receberá instruções para redefinir sua senha.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.gray),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('Voltar para o login', style: TextStyle(color: AppColors.teal, fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

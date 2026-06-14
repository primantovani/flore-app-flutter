import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos'),
          backgroundColor: Color(0xFFd4541a),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
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
      backgroundColor: const Color(0xFFf7f5f2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 14),
              _buildPasswordField(),
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
            color: const Color(0xFF2a7d70),
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
            color: Color(0xFF1a5c52),
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'CLOSET CIRCULAR',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFd4541a),
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1e1e1e)),
        ),
        SizedBox(height: 4),
        Text(
          'Entre na sua conta para continuar',
          style: TextStyle(fontSize: 14, color: Color(0xFF6b6b6b)),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('E-mail', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a5c52))),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1e1e1e)),
          decoration: InputDecoration(
            hintText: 'seu@email.com',
            hintStyle: const TextStyle(color: Color(0xFFaaaaaa)),
            prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF2a7d70), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe0e0e0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe0e0e0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2a7d70), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Senha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a5c52))),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1e1e1e)),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Color(0xFFaaaaaa)),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2a7d70), size: 20),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF6b6b6b), size: 20),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe0e0e0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe0e0e0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2a7d70), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: const Text(
          'Esqueci minha senha',
          style: TextStyle(fontSize: 12, color: Color(0xFF2a7d70), fontWeight: FontWeight.w600),
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
            color: const Color(0xFF2a7d70),
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
      const Expanded(child: Divider(color: Color(0xFFe0e0e0))),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('ou', style: TextStyle(color: Color(0xFF6b6b6b), fontSize: 12)),
      ),
      const Expanded(child: Divider(color: Color(0xFFe0e0e0))),
    ]);
  }

  Widget _buildSignupLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Não tem uma conta? ', style: TextStyle(color: Color(0xFF6b6b6b), fontSize: 13)),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
        child: const Text('Cadastre-se', style: TextStyle(color: Color(0xFF2a7d70), fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

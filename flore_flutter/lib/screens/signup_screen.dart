import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _signup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf7f5f2),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1a5c52), size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildTitle(),
              const SizedBox(height: 32),
              _buildField('Nome completo', 'Priscila Mantovani', Icons.person_outline, _nameController, false),
              const SizedBox(height: 14),
              _buildField('E-mail', 'seu@email.com', Icons.mail_outline, _emailController, false),
              const SizedBox(height: 14),
              _buildPasswordField(),
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
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Criar conta',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1e1e1e)),
        ),
        SizedBox(height: 4),
        Text(
          'Faça parte da moda circular',
          style: TextStyle(fontSize: 14, color: Color(0xFF6b6b6b)),
        ),
      ],
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a5c52))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1e1e1e)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFaaaaaa)),
            prefixIcon: Icon(icon, color: const Color(0xFF2a7d70), size: 20),
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
            hintText: 'Mínimo 6 caracteres',
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

  Widget _buildTerms() {
    return Row(children: [
      const Icon(Icons.check_circle_outline, color: Color(0xFF2a7d70), size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 12, color: Color(0xFF6b6b6b)),
            children: [
              TextSpan(text: 'Concordo com os '),
              TextSpan(text: 'Termos de Uso', style: TextStyle(color: Color(0xFF2a7d70), fontWeight: FontWeight.w600)),
              TextSpan(text: ' e '),
              TextSpan(text: 'Política de Privacidade', style: TextStyle(color: Color(0xFF2a7d70), fontWeight: FontWeight.w600)),
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
            color: const Color(0xFFd4541a),
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
      const Text('Já tem uma conta? ', style: TextStyle(color: Color(0xFF6b6b6b), fontSize: 13)),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text('Entrar', style: TextStyle(color: Color(0xFF2a7d70), fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

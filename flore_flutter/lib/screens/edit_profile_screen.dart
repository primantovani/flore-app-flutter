import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  final AuthService? authService;

  const EditProfileScreen({super.key, required this.user, this.authService});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _authService = widget.authService ?? AuthService();
  late final _nameController = TextEditingController(text: widget.user.name);
  late final _emailController = TextEditingController(text: widget.user.email);
  bool _isLoading = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final updated = await _authService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (mounted) Navigator.pop(context, updated);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível salvar seu perfil. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.orange, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Editar perfil', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Salvar alterações', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

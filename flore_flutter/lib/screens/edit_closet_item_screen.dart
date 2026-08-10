import 'package:flutter/material.dart';
import '../models/closet_item.dart';
import '../services/closet_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';

/// Cadastro/edição de peça do closet (item 2). [existingItem] nulo = cadastro
/// de peça nova; preenchido = edição de uma peça existente.
class EditClosetItemScreen extends StatefulWidget {
  final ClosetItem? existingItem;
  final ClosetService? closetService;

  const EditClosetItemScreen({super.key, this.existingItem, this.closetService});

  @override
  State<EditClosetItemScreen> createState() => _EditClosetItemScreenState();
}

class _EditClosetItemScreenState extends State<EditClosetItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _closetService = widget.closetService ?? ClosetService();
  late final _nameController = TextEditingController(text: widget.existingItem?.name);
  late final _categoryController = TextEditingController(text: widget.existingItem?.category);
  late final _priceController = TextEditingController(
    text: widget.existingItem?.price.toStringAsFixed(2),
  );
  late final _descriptionController = TextEditingController(text: widget.existingItem?.description);
  bool _isLoading = false;

  bool get _isEditing => widget.existingItem != null;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final price = double.parse(_priceController.text.trim().replaceAll(',', '.'));
      final ClosetItem saved;
      if (_isEditing) {
        saved = await _closetService.updateItem(widget.existingItem!.copyWith(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          price: price,
          description: _descriptionController.text.trim(),
        ));
      } else {
        saved = await _closetService.createItem(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          price: price,
          description: _descriptionController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, saved);
    } on ClosetException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível salvar a peça. Tente novamente.');
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
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar peça' : 'Cadastrar peça', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Nome da peça',
                  hint: 'Vestido Floral Midi',
                  icon: Icons.checkroom_outlined,
                  controller: _nameController,
                  validator: (v) => Validators.required(v, message: 'Informe o nome da peça'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Categoria',
                  hint: 'Vestidos',
                  icon: Icons.category_outlined,
                  controller: _categoryController,
                  validator: (v) => Validators.required(v, message: 'Informe a categoria'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Valor (R\$)',
                  hint: '120.00',
                  icon: Icons.attach_money,
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.price,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Descrição (opcional)',
                  hint: 'Estado de conservação, tamanho, detalhes...',
                  icon: Icons.notes_outlined,
                  controller: _descriptionController,
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
                            : Text(_isEditing ? 'Salvar alterações' : 'Cadastrar peça',
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
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

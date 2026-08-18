/// Validadores de formulário (Melhoria C). Antes login/signup só checavam
/// campo vazio; aqui validamos formato de e-mail e tamanho mínimo de senha.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w\.\-\+]+@[\w\-]+(\.[\w\-]+)*\.[a-zA-Z]{2,}$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu nome';
    }
    if (value.trim().length < 3) {
      return 'Nome muito curto';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu e-mail';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha';
    }
    if (value.length < 6) {
      return 'Mínimo de 6 caracteres';
    }
    return null;
  }

  static String? required(String? value, {String message = 'Campo obrigatório'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o valor';
    }
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return 'Valor inválido';
    }
    return null;
  }
}

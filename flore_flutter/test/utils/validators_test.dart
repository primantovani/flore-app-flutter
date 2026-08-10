import 'package:flutter_test/flutter_test.dart';
import 'package:flore_flutter/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejeita vazio e formato inválido', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('nao-e-email'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });

    test('aceita e-mail válido', () {
      expect(Validators.email('priscila@flore.com.br'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejeita senha curta', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('aceita senha com 6+ caracteres', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.price', () {
    test('rejeita valor não numérico ou zero', () {
      expect(Validators.price('abc'), isNotNull);
      expect(Validators.price('0'), isNotNull);
      expect(Validators.price(''), isNotNull);
    });

    test('aceita vírgula como separador decimal', () {
      expect(Validators.price('120,50'), isNull);
    });
  });
}

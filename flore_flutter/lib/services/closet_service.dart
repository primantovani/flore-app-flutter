import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/closet_item.dart';
import 'auth_service.dart';

enum ClosetErrorType { unauthorized, notFound, timeout, network, server }

class ClosetException implements Exception {
  final ClosetErrorType type;
  final String message;

  const ClosetException(this.type, this.message);

  @override
  String toString() => message;
}

/// CRUD real do closet circular (item 2 + Melhoria D aplicada aqui: erros
/// não são engolidos, cada chamada expõe estado de sucesso/erro explícito
/// pra tela decidir o que mostrar).
class ClosetService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  final http.Client _client;
  final AuthService _authService;

  ClosetService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Peças do usuário logado ("Meu Closet"), incluindo vendidas.
  Future<List<ClosetItem>> getMyCloset() async {
    final headers = await _authHeaders();
    return _getList('$_baseUrl/api/closet/mine', headers);
  }

  /// Peças disponíveis de todas as usuárias ("Marketplace"), público.
  Future<List<ClosetItem>> getMarketplace() async {
    final headers = await _authHeaders();
    return _getList('$_baseUrl/api/closet', headers);
  }

  Future<List<ClosetItem>> _getList(String url, Map<String, String> headers) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: headers).timeout(AppConfig.requestTimeout);
      _throwIfError(response);
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => ClosetItem.fromJson(e as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw const ClosetException(ClosetErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.');
    } on ClosetException {
      rethrow;
    } catch (_) {
      throw const ClosetException(ClosetErrorType.server, 'Não foi possível carregar as peças.');
    }
  }

  Future<ClosetItem> createItem({
    required String name,
    required String category,
    required double price,
    String? description,
  }) async {
    final headers = await _authHeaders();
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/closet'),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'category': category,
              'price': price,
              if (description != null && description.isNotEmpty) 'description': description,
            }),
          )
          .timeout(AppConfig.requestTimeout);
      _throwIfError(response);
      return ClosetItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw const ClosetException(ClosetErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.');
    } on ClosetException {
      rethrow;
    } catch (_) {
      throw const ClosetException(ClosetErrorType.server, 'Não foi possível cadastrar a peça.');
    }
  }

  Future<ClosetItem> updateItem(ClosetItem item) async {
    final headers = await _authHeaders();
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/api/closet/${item.id}'),
            headers: headers,
            body: jsonEncode(item.toCreateJson()),
          )
          .timeout(AppConfig.requestTimeout);
      _throwIfError(response);
      return ClosetItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw const ClosetException(ClosetErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.');
    } on ClosetException {
      rethrow;
    } catch (_) {
      throw const ClosetException(ClosetErrorType.server, 'Não foi possível salvar as alterações.');
    }
  }

  Future<void> markAsSold(String itemId) async {
    final headers = await _authHeaders();
    try {
      final response = await _client
          .patch(Uri.parse('$_baseUrl/api/closet/$itemId/status?status=sold'), headers: headers)
          .timeout(AppConfig.requestTimeout);
      _throwIfError(response);
    } on TimeoutException {
      throw const ClosetException(ClosetErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.');
    } on ClosetException {
      rethrow;
    } catch (_) {
      throw const ClosetException(ClosetErrorType.server, 'Não foi possível marcar a peça como vendida.');
    }
  }

  Future<void> deleteItem(String itemId) async {
    final headers = await _authHeaders();
    try {
      final response = await _client
          .delete(Uri.parse('$_baseUrl/api/closet/$itemId'), headers: headers)
          .timeout(AppConfig.requestTimeout);
      _throwIfError(response);
    } on TimeoutException {
      throw const ClosetException(ClosetErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.');
    } on ClosetException {
      rethrow;
    } catch (_) {
      throw const ClosetException(ClosetErrorType.server, 'Não foi possível remover a peça.');
    }
  }

  /// Fluxo de compra: usuária compra uma peça de outro usuário.
  Future<void> buyItem(String itemId) async {
    final headers = await _authHeaders();
    try {
      final response = await _client
          .post(Uri.parse('$_baseUrl/api/closet/$itemId/buy'), headers: headers)
          .timeout(AppConfig.requestTimeout);
      _throwIfError(response);
    } on TimeoutException {
      throw const ClosetException(ClosetErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.');
    } on ClosetException {
      rethrow;
    } catch (_) {
      throw const ClosetException(ClosetErrorType.server, 'Não foi possível concluir a compra.');
    }
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    switch (response.statusCode) {
      case 401:
      case 403:
        throw const ClosetException(ClosetErrorType.unauthorized, 'Sessão expirada. Faça login novamente.');
      case 404:
        throw const ClosetException(ClosetErrorType.notFound, 'Peça não encontrada.');
      default:
        throw const ClosetException(ClosetErrorType.server, 'Não foi possível completar a operação.');
    }
  }
}

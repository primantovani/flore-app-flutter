import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/app_user.dart';

enum AuthErrorType { invalidCredentials, emailInUse, timeout, network, server }

class AuthException implements Exception {
  final AuthErrorType type;
  final String message;

  const AuthException(this.type, this.message);

  @override
  String toString() => message;
}

/// Autenticação real contra o backend (Melhoria E + item 1).
/// Antes login/signup só faziam `Future.delayed` e navegavam direto,
/// sem chamar endpoint nenhum nem guardar sessão.
class AuthService {
  static const String _baseUrl = AppConfig.apiBaseUrl;
  static const String _tokenKey = 'flore_auth_token';
  static const String _userKey = 'flore_auth_user';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<AppUser> login({required String email, required String password}) async {
    final Map<String, dynamic> body;
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 8));
      body = _handleAuthResponse(response);
    } on TimeoutException {
      throw const AuthException(AuthErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const AuthException(AuthErrorType.network, 'Sem conexão com o servidor.');
    }

    return _persistSession(body);
  }

  Future<AppUser> signup({required String name, required String email, required String password}) async {
    final Map<String, dynamic> body;
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/auth/signup'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 8));
      body = _handleAuthResponse(response);
    } on TimeoutException {
      throw const AuthException(AuthErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const AuthException(AuthErrorType.network, 'Sem conexão com o servidor.');
    }

    return _persistSession(body);
  }

  Map<String, dynamic> _handleAuthResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body) as Map<String, dynamic>;
      case 401:
        throw const AuthException(AuthErrorType.invalidCredentials, 'E-mail ou senha incorretos.');
      case 409:
        throw const AuthException(AuthErrorType.emailInUse, 'Já existe uma conta com esse e-mail.');
      default:
        throw const AuthException(AuthErrorType.server, 'Não foi possível completar a operação. Tente novamente.');
    }
  }

  Future<AppUser> _persistSession(Map<String, dynamic> body) async {
    final token = body['token'] as String?;
    final userJson = body['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      throw const AuthException(AuthErrorType.server, 'Resposta inesperada do servidor.');
    }
    final user = AppUser.fromJson(userJson);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<AppUser> updateProfile({required String name, required String email}) async {
    final token = await getToken();
    final Map<String, dynamic> body;
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/api/auth/profile'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'name': name, 'email': email}),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw const AuthException(AuthErrorType.server, 'Não foi possível salvar seu perfil. Tente novamente.');
      }
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw const AuthException(AuthErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const AuthException(AuthErrorType.network, 'Sem conexão com o servidor.');
    }

    final user = AppUser.fromJson((body['user'] as Map<String, dynamic>?) ?? body);
    await updateCurrentUser(user);
    return user;
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/auth/forgot-password'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode >= 500) {
        throw const AuthException(AuthErrorType.server, 'Não foi possível enviar o e-mail agora. Tente novamente.');
      }
      // 200/202/404 são tratados como sucesso na UI: não revelamos se o
      // e-mail existe ou não por questão de segurança.
    } on TimeoutException {
      throw const AuthException(AuthErrorType.timeout, 'Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw const AuthException(AuthErrorType.network, 'Sem conexão com o servidor.');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> updateCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

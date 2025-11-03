import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

typedef TokenSaver = Future<void> Function(String token);

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) {
    String _toString(dynamic v) => v?.toString() ?? '';

    return AuthUser(
      id: _toString(j['id']),
      name: _toString(j['name']),
      email: _toString(j['email']),
      token: _toString(j['token']),
    );
  }

  bool get hasToken => token.isNotEmpty;
}

class LoginResult {
  final String status;
  final String message;
  final AuthUser? user;

  const LoginResult({
    required this.status,
    required this.message,
    required this.user,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory LoginResult.fromJson(Map<String, dynamic> j) {
    final status = (j['status'] ?? '').toString();
    final message = (j['message'] ?? '').toString();

    AuthUser? parsedUser;
    if (j['user'] is Map<String, dynamic>) {
      parsedUser = AuthUser.fromJson(j['user'] as Map<String, dynamic>);
    }

    return LoginResult(status: status, message: message, user: parsedUser);
  }
}

class SignupResult {
  final String status;
  final String message;

  const SignupResult({required this.status, required this.message});

  bool get isSuccess => status.toLowerCase() == 'success';

  factory SignupResult.fromJson(Map<String, dynamic> j) {
    return SignupResult(
      status: (j['status'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
    );
  }
}

class AuthService {
  AuthService({TokenSaver? saveToken})
    : _saveToken = saveToken ?? TokenStorage.saveToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenSaver _saveToken;

  Future<SignupResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final uri = Uri.parse('$_base/signup.php');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });

    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      log('Signup HTTP ${res.statusCode} ${res.body}');
      throw Exception(
        'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Signup failed'}',
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected signup response format');
    }

    final result = SignupResult.fromJson(decoded);
    return result;
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final uri = Uri.parse('$_base/login.php');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({'email': email.trim(), 'password': password});

    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      log('Login HTTP ${res.statusCode} ${res.body}');
      throw Exception(
        'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Login failed'}',
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected login response format');
    }

    final result = LoginResult.fromJson(decoded);

    // if backend said success, store token (if present)
    if (result.isSuccess && result.user != null && result.user!.hasToken) {
      await _saveToken(result.user!.token);
    }

    return result;
  }
}

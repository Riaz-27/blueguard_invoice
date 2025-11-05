import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ServicesList {
  final bool success;
  final List<String> items;
  final String message;

  const ServicesList({
    required this.success,
    required this.items,
    this.message = '',
  });

  bool get isSuccess => success;

  factory ServicesList.fromJson(Map<String, dynamic> j) {
    final ok = (j['success'] == true);
    final raw = j['data'];

    final items = (raw is List)
        ? raw.map((e) => e.toString()).toList()
        : <String>[];

    return ServicesList(
      success: ok,
      items: items,
      message: (j['message'] ?? '').toString(),
    );
  }
}

class ServicesService {
  ServicesService()
    : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  Future<ServicesList> fetchServices() async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final uri = Uri.parse('$_base/services.php');
    final headers = <String, String>{'Accept': 'application/json'};

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = ServicesList.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception(
        parsed.message.isNotEmpty ? parsed.message : 'Failed to load services',
      );
    }
    return parsed;
  }

  /// Convenience helper to just get the names.
  Future<List<String>> fetchServiceNames() async {
    final p = await fetchServices();
    return p.items;
  }
}

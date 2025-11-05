import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TaxRate {
  final int id;
  final String area;
  final String taxNo;
  final double percent;

  const TaxRate({
    required this.id,
    required this.area,
    required this.taxNo,
    required this.percent,
  });

  /// Fraction helper (10% -> 0.10)
  double get fraction => percent / 100.0;

  factory TaxRate.fromJson(Map<String, dynamic> j) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse((v ?? '').toString()) ?? 0.0;
    }

    return TaxRate(
      id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      area: (j['area'] ?? '').toString(),
      taxNo: (j['tax_no'] ?? '').toString(),
      percent: toDouble(j['percentage']),
    );
  }
}

class TaxesResponse {
  final bool success;
  final List<TaxRate> data;
  final String message;

  const TaxesResponse({
    required this.success,
    required this.data,
    this.message = '',
  });

  bool get isSuccess => success;

  factory TaxesResponse.fromJson(Map<String, dynamic> j) {
    final ok = (j['success'] == true);
    final list = (j['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TaxRate.fromJson)
        .toList();

    return TaxesResponse(
      success: ok,
      data: list,
      message: (j['message'] ?? '').toString(),
    );
  }
}

class TaxesService {
  TaxesService()
    : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  Future<TaxesResponse> fetchTaxes() async {
    if (_base.isEmpty) {
      throw StateError('Server URL is empty');
    }

    final uri = Uri.parse('$_base/taxes.php');
    final res = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = TaxesResponse.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception(
        parsed.message.isNotEmpty ? parsed.message : 'Failed to load taxes',
      );
    }
    return parsed;
  }

  /// Convenience: area -> fraction (e.g. {"Dhaka": 0.10})
  Future<Map<String, double>> fetchTaxMap() async {
    final r = await fetchTaxes();
    return {for (final t in r.data) t.area: t.fraction};
  }
}

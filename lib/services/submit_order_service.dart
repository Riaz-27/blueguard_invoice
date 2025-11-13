import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/cutomer_info.dart';
import '../models/service_item.dart';

class SubmitOrderResult {
  final bool success;
  final String message;

  const SubmitOrderResult({required this.success, required this.message});

  factory SubmitOrderResult.fromJson(Map<String, dynamic> json) {
    final s = json['success'];
    final m = (json['message'] ?? '').toString();
    return SubmitOrderResult(
      success: s is bool ? s : (s.toString() == 'true'),
      message: m,
    );
  }
}

class SubmitOrderService {
  SubmitOrderService()
    : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  Future<SubmitOrderResult> submitOrder({
    required CustomerInfo customer,
    required List<ServiceItem> services,
    required double taxPercent,
    required double totalPrice,
    required String nextServiceDate,
    required String comments,
    required String taxNo,
    required String paymentMethod,
    String unit = '',
    String type = 'order',
  }) async {
    if (_base.isEmpty) {
      throw StateError('Server URL is empty');
    }

    final uri = Uri.parse('$_base/submit_order.php');

    // "15%" style label (no trailing .00 when whole)
    String _percentLabel(double p) {
      final v = p * 100.0;
      final isWhole = v.truncateToDouble() == v;
      return isWhole ? '${v.toStringAsFixed(0)}%' : '${v.toStringAsFixed(2)}%';
    }

    final taxSlabStr = _percentLabel(taxPercent);

    // services array
    final serviceList = services
        .map((s) => {"name": s.name, "price": s.price, "qty": s.qty})
        .toList();

    final bodyMap = {
      "type": type,
      "firstName": customer.firstName,
      "lastName": customer.lastName,
      "address": customer.street,
      "city": customer.city,
      "unit": unit, // pass '' if you don't collect it yet
      "province": customer.province,
      "postalCode": customer.postalCode,
      "contactNumber": customer.phone,
      "email": customer.email,
      "taxSlab": taxSlabStr,
      "tax_no": taxNo,
      "totalPrice": totalPrice,
      "payment_method": paymentMethod,
      "nextServiceDate": nextServiceDate,
      "comments": comments,
      "services": serviceList,
    };

    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(bodyMap))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Unexpected response: ${res.body}");
    }

    return SubmitOrderResult.fromJson(decoded);
  }
}

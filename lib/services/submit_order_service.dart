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
  }) async {
    if (_base.isEmpty) {
      throw StateError('Server URL is empty');
    }

    final uri = Uri.parse('$_base/submit_order.php');

    final taxSlabStr = "${(taxPercent * 100).toStringAsFixed(2)}%";

    // services array
    final serviceList = services.map((s) {
      return {"name": s.name, "price": s.price, "qty": s.qty};
    }).toList();

    final bodyMap = {
      "firstName": customer.firstName,
      "lastName": customer.lastName,
      "address": customer.street,
      "city": customer.city,
      "province": customer.province,
      "postalCode": customer.postalCode,
      "contactNumber": customer.phone,
      "email": customer.email,
      "taxSlab": taxSlabStr,
      "totalPrice": totalPrice, // number
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

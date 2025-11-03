import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../services/invoice_pdf_service.dart';
import '../../services/submit_order_service.dart';

class ServiceItem {
  String name;
  double price;
  int qty;

  ServiceItem({required this.name, required this.price, required this.qty});
}

class CustomerInfo {
  final String firstName;
  final String lastName;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final String email;
  final String phone;

  const CustomerInfo({
    required this.firstName,
    required this.lastName,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.email,
    required this.phone,
  });
}

class OrderDetailsController extends GetxController {
  late CustomerInfo customerInfo;

  @override
  void onInit() {
    super.onInit();
    // default fallback so nothing crashes if you navigate directly
    customerInfo = const CustomerInfo(
      firstName: "test",
      lastName: "test",
      street: "test",
      city: "Chittagong",
      province: "Chittagong",
      postalCode: "123234",
      email: "riaz.uddin27@gmail.com",
      phone: "01812345678",
    );
  }

  void setCustomerInfoFromMap(Map<String, dynamic> m) {
    customerInfo = CustomerInfo(
      firstName: m["firstName"] ?? "",
      lastName: m["lastName"] ?? "",
      street: m["street"] ?? "",
      city: m["city"] ?? "",
      province: m["province"] ?? "",
      postalCode: m["postalCode"] ?? "",
      email: m["email"] ?? "",
      phone: m["phone"] ?? "",
    );
  }

  /// Cart-like services. qty 0 means not taken, qty>0 taken.
  final RxList<ServiceItem> services = <ServiceItem>[
    ServiceItem(name: "Air duct cleaning", price: 0, qty: 0),
    ServiceItem(name: "Air exchanger cleaning", price: 500, qty: 1),
    ServiceItem(name: "Heat pump cleaning W/split unit", price: 0, qty: 0),
    ServiceItem(name: "Dryer vent cleaning", price: 0, qty: 0),
    ServiceItem(name: "Furnace blower cleaning", price: 0, qty: 0),
    ServiceItem(
      name: "Power cleaning with sweeper line method",
      price: 0,
      qty: 0,
    ),
    ServiceItem(name: "Central vacuum cleaning with outlet", price: 0, qty: 0),
    ServiceItem(name: "Sanitizing with spray bottle", price: 0, qty: 0),
    ServiceItem(name: "Sanitization with fogger", price: 0, qty: 0),
    ServiceItem(name: "Additional Services", price: 0, qty: 0),
  ].obs;

  final List<String> serviceOptions = const [
    "Air duct cleaning",
    "Air exchanger cleaning",
    "Heat pump cleaning W/split unit",
    "Dryer vent cleaning",
    "Furnace blower cleaning",
    "Power cleaning with sweeper line method",
    "Central vacuum cleaning with outlet",
    "Sanitizing with spray bottle",
    "Sanitization with fogger",
    "Additional Services",
  ];

  final Map<String, double> taxRates = const {
    "QC": 0.15,
    "ON": 0.13,
    "NS": 0.15,
    "NB": 0.15,
  };

  final RxString selectedProvince = "QC".obs;

  final nextServiceDateCtrl = TextEditingController(text: "2025-11-05");
  final commentCtrl = TextEditingController(
    text: "Heating and cooling system checked. Systems working properly",
  );

  final RxString commentType =
      "Heating and cooling system checked. Systems working properly".obs;
  final List<String> commentOptions = const [
    "Heating and cooling system checked. Systems working properly",
    "Recommend filter replacement soon",
    "Customer requested callback",
    "Unable to access location",
    "Other",
  ];

  final isSubmitting = false.obs;

  final _submitOrderService = SubmitOrderService();

  // ---- calculations ----
  double get subTotal {
    double total = 0;
    for (final s in services) {
      total += s.price * s.qty;
    }
    return total;
  }

  double get taxPercent {
    return taxRates[selectedProvince.value] ?? 0.0;
  }

  double get taxAmount {
    return subTotal * taxPercent;
  }

  double get totalAfterTax {
    return subTotal + taxAmount;
  }

  // ---- service list mutations ----
  void addService({
    required String name,
    required double price,
    required int qty,
  }) {
    services.add(ServiceItem(name: name, price: price, qty: qty));
    services.refresh();
  }

  void incrementQty(int index) {
    if (index < 0 || index >= services.length) return;
    services[index].qty += 1;
    services.refresh();
  }

  void decrementQty(int index) {
    if (index < 0 || index >= services.length) return;
    if (services[index].qty > 0) {
      services[index].qty -= 1;
      services.refresh();
    }
  }

  void removeService(int index) {
    if (index < 0 || index >= services.length) return;
    services.removeAt(index);
    services.refresh();
  }

  void selectProvince(String code) {
    selectedProvince.value = code;
  }

  Future<void> pickNextServiceDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );

    if (picked != null) {
      final yyyy = picked.year.toString();
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      nextServiceDateCtrl.text = "$yyyy-$mm-$dd";
    }
  }

  // ---- NEXT: first submit_order.php, then generate PDF ----
  Future<void> onNext() async {
    if (services.isEmpty) {
      Get.snackbar("No services", "Please add at least one service.");
      return;
    }

    isSubmitting.value = true;
    try {
      //TODO COMENTED FOR TESTING NOW
      // 1. submit order to backend
      // final apiResult = await _submitOrderService.submitOrder(
      //   customer: customerInfo,
      //   services: services.toList(),
      //   taxPercent: taxPercent,
      //   totalPrice: totalAfterTax,
      //   nextServiceDate: nextServiceDateCtrl.text.trim(),
      //   comments: commentCtrl.text.trim(),
      // );

      // if (!apiResult.success) {
      //   Get.snackbar(
      //     "Order Failed",
      //     apiResult.message.isEmpty
      //         ? "Could not save order"
      //         : apiResult.message,
      //   );
      //   isSubmitting.value = false;
      //   return;
      // }

      // 2. Load assets for PDF
      // NOTE: update paths if different in your assets folder
      final fullPageData = await rootBundle.load('assets/terms.jpg');
      final fullPageImageBytes = fullPageData.buffer.asUint8List();

      final logoData = await rootBundle.load('assets/logo.webp');
      final logoBytes = logoData.buffer.asUint8List();

      // 3. Generate the PDF (page 1 + page 2)
      final invoiceNo = _generateInvoiceNumber();
      final now = DateTime.now();

      await InvoicePdfService.generateAndOpenInvoicePdf(
        invoiceNumber: invoiceNo,
        invoiceDate: now,
        customer: customerInfo,
        services: services.toList(),
        subTotal: subTotal,
        taxPercent: taxPercent,
        taxAmount: taxAmount,
        total: totalAfterTax,
        remarks: commentCtrl.text.trim(),
        nextServiceDate: nextServiceDateCtrl.text.trim(),
        fullPageImageBytes: fullPageImageBytes,
        logoBytes: logoBytes,
      );

      // Get.snackbar(
      //   "Success",
      //   apiResult.message.isNotEmpty
      //       ? apiResult.message
      //       : "Order saved & PDF generated.",
      // );

      // Optional navigation after success
      // Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  String _generateInvoiceNumber() {
    // Just a pseudo-unique invoice number like "25110001"
    final r = Random().nextInt(900000) + 100000;
    final y = DateTime.now().year.toString().substring(2);
    return "$y$r";
  }

  @override
  void onClose() {
    nextServiceDateCtrl.dispose();
    commentCtrl.dispose();
    super.onClose();
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:invoice/modules/home/home_controller.dart';

import '../../models/cutomer_info.dart';
import '../../models/service_item.dart';
import '../../routes/app_routes.dart';
import '../../services/invoice_pdf_service.dart';
import '../../services/submit_order_service.dart';

class OrderDetailsController extends GetxController {
  late final CustomerInfo customerInfo;

  final RxList<ServiceItem> services = <ServiceItem>[].obs;

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

  final Map<String, double> taxRates = const {"QC": 0.15, "ON": 0.13};

  final RxString selectedTaxSlab = "QC".obs;

  final nextServiceDateCtrl = TextEditingController(text: "2025-11-05");
  final commentCtrl = TextEditingController();

  final RxString commentType = "Select a preset".obs;
  final List<String> commentOptions = const [
    "Select a preset",
    "Heating and cooling system checked. Systems working properly",
    "Recommend filter replacement soon",
    "Customer requested callback",
    "Unable to access location",
    "Other",
  ];

  final isSubmitting = false.obs;

  final _submitOrderService = SubmitOrderService();

  final selectedServiceDate = DateTime.now().add(Duration(days: 30)).obs;

  // calculations
  double get subTotal {
    double total = 0;
    for (final s in services) {
      total += s.price * s.qty;
    }
    return (total * 100).round() / 100;
  }

  double get taxPercent {
    return taxRates[selectedTaxSlab.value] ?? 0.0;
  }

  double get taxAmount {
    return ((subTotal * taxPercent) * 100).round() / 100;
  }

  double get totalAfterTax {
    return subTotal + taxAmount;
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments?['customerInfo'] != null) {
      customerInfo = Get.arguments?['customerInfo'] as CustomerInfo;
    } else {
      customerInfo = CustomerInfo(
        firstName: "",
        lastName: "",
        street: "",
        city: "",
        province: "",
        postalCode: "",
        email: "",
        phone: "",
      );
    }

    // setting deafult next service date to next month
    final nextMonth = selectedServiceDate.value;
    final yyyy = nextMonth.year.toString();
    final mm = nextMonth.month.toString().padLeft(2, '0');
    final dd = nextMonth.day.toString().padLeft(2, '0');

    nextServiceDateCtrl.text = '$yyyy-$mm-$dd';
  }

  // service list mutations
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
    if (services[index].qty > 1) {
      services[index].qty -= 1;
      services.refresh();
    }
  }

  void removeService(int index) {
    if (index < 0 || index >= services.length) return;
    services.removeAt(index);
    services.refresh();
  }

  void selectTaxSlab(String code) {
    selectedTaxSlab.value = code;
  }

  Future<void> pickNextServiceDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
      initialDate: selectedServiceDate.value,
    );

    if (picked != null) {
      selectedServiceDate.value = picked;
      final yyyy = picked.year.toString();
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      nextServiceDateCtrl.text = "$yyyy-$mm-$dd";
    }
  }

  void updateService({
    required int index,
    required String name,
    required double price,
    required int qty,
  }) {
    final item = services[index];
    services[index] = item.copyWith(name: name, price: price, qty: qty);
    services.refresh();
  }

  Future<void> onNext() async {
    if (services.isEmpty) {
      Get.snackbar("No services", "Please add at least one service.");
      return;
    }

    isSubmitting.value = true;
    try {
      // submit order to backend
      final apiResult = await _submitOrderService.submitOrder(
        customer: customerInfo,
        services: services.toList(),
        taxPercent: taxPercent,
        totalPrice: totalAfterTax,
        nextServiceDate: nextServiceDateCtrl.text.trim(),
        comments: commentCtrl.text.trim(),
      );

      if (!apiResult.success) {
        Get.snackbar(
          "Order Failed",
          apiResult.message.isEmpty
              ? "Could not save order"
              : apiResult.message,
        );
        isSubmitting.value = false;
        return;
      }

      // Load assets for PDF
      final fullPageData = await rootBundle.load('assets/terms.jpg');
      final fullPageImageBytes = fullPageData.buffer.asUint8List();

      final logoData = await rootBundle.load('assets/logo.webp');
      final logoBytes = logoData.buffer.asUint8List();

      // Generate the PDF
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

      // after success
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  String _generateInvoiceNumber() {
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

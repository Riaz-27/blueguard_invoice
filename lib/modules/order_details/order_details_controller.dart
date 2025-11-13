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

// NEW
import '../../services/services_service.dart';
import '../../services/taxes_service.dart';
import '../../services/comments_service.dart';

class OrderDetailsController extends GetxController {
  late final CustomerInfo customerInfo;

  final isLoading = false.obs;

  final RxList<ServiceItem> services = <ServiceItem>[].obs;
  final RxList<String> serviceOptions = <String>[].obs;

  final RxMap<String, double> taxRates = <String, double>{}.obs;
  final RxMap<String, String> taxNos = <String, String>{}.obs;

  final ScrollController scrollController = ScrollController();
  final RxString selectedTaxSlab = ''.obs;
  final GlobalKey itemKey = GlobalKey();

  final RxnString commentType = RxnString();
  final RxList<String> commentOptions = <String>[].obs;

  final nextServiceDateCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  final isSubmitting = false.obs;
  final _submitOrderService = SubmitOrderService();

  final selectedServiceDate = DateTime.now().add(const Duration(days: 30)).obs;

  // ----------------- Calculations -----------------
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

  double get totalAfterTax => subTotal + taxAmount;

  String get selectedTaxNo => taxNos[selectedTaxSlab.value] ?? '';

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

    // default next service date = +30 days
    final d = selectedServiceDate.value;
    nextServiceDateCtrl.text =
        '${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';

    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _loadServices(),
      _loadComments(),
      _loadTaxesAndSelectDefault(),
    ]);

    // Delay scroll until after ListView rebuilds with new data
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToSelectedItem();
    });

    isLoading.value = false;
  }

  void _scrollToSelectedItem() {
    if (itemKey.currentContext == null) return;

    final RenderBox box =
        itemKey.currentContext!.findRenderObject() as RenderBox;
    final double itemWidth = box.size.width;

    final selectedIndex = taxRates.keys.toList().indexWhere(
      (val) => selectedTaxSlab.value == val,
    );

    if (selectedIndex < 0) return;

    final double screenWidth = Get.width;

    double position =
        (selectedIndex * (itemWidth + 16)) -
        (screenWidth / 2) +
        (itemWidth / 2);

    position = position.clamp(0.0, scrollController.position.maxScrollExtent);

    scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadServices() async {
    try {
      final names = await ServicesService().fetchServiceNames();
      serviceOptions.assignAll(names);
    } catch (e) {
      Get.snackbar('Services', e.toString());
    }
  }

  Future<void> _loadComments() async {
    try {
      final presets = await CommentsService().fetchCommentPresets();
      commentOptions.assignAll(['Select a preset', ...presets]);
      commentType.value = 'Select a preset';
    } catch (e) {
      Get.snackbar('Comments', e.toString());
    }
  }

  Future<void> _loadTaxesAndSelectDefault() async {
    try {
      final resp = await TaxesService().fetchTaxes();

      taxRates.assignAll({for (final t in resp.data) t.area: t.fraction});
      taxNos.assignAll({for (final t in resp.data) t.area: t.taxNo});

      // auto-select by matching province
      final prov = (customerInfo.province).toString().trim().toLowerCase();
      String? match;
      if (prov.isNotEmpty) {
        for (final area in taxRates.keys) {
          final a = area.toLowerCase();
          if (prov.contains(a) || a.contains(prov)) {
            match = area;
            break;
          }
        }
      }
      final chosen =
          match ?? (taxRates.keys.isNotEmpty ? taxRates.keys.first : '');
      selectedTaxSlab.value = chosen;
    } catch (e) {
      Get.snackbar('Taxes', e.toString());
      if (taxRates.isNotEmpty) {
        final first = taxRates.keys.first;
        selectedTaxSlab.value = first;
      }
    }
  }

  // ----------------- Mutations -----------------
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

  void selectTaxSlab(String area) {
    selectedTaxSlab.value = area;
  }

  void onCommentChange(String? preset) {
    if (preset != null) {
      commentType.value = preset;
      if (preset == 'Select a preset') {
        commentCtrl.text += '';
      } else {
        if (commentCtrl.text.isEmpty) {
          commentCtrl.text = preset;
        } else {
          if (!commentCtrl.text.contains(preset)) {
            commentCtrl.text += ' $preset';
          }
        }
      }
    }
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
      nextServiceDateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}';
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

  // ----------------- Submit & PDF -----------------
  Future<void> onNext() async {
    if (services.isEmpty) {
      Get.snackbar("No services", "Please add at least one service.");
      return;
    }

    isSubmitting.value = true;
    try {
      //Submit order
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

      // Load assets for PDF pages
      final fullPageData = await rootBundle.load('assets/terms.jpg');
      final fullPageImageBytes = fullPageData.buffer.asUint8List();

      final logoData = await rootBundle.load('assets/logo.png');
      final logoBytes = logoData.buffer.asUint8List();

      //Generate PDF
      final invoiceNo = _generateInvoiceNumber();
      final now = DateTime.now();

      await InvoicePdfService.generateAndOpenInvoicePdf(
        invoiceNumber: invoiceNo,
        invoiceDate: now,
        customer: customerInfo,
        services: services.toList(),
        subTotal: subTotal,
        taxPercent: taxPercent,
        taxNo: selectedTaxNo,
        taxAmount: taxAmount,
        total: totalAfterTax,
        remarks: commentCtrl.text.trim(),
        nextServiceDate: nextServiceDateCtrl.text.trim(),
        fullPageImageBytes: fullPageImageBytes,
        logoBytes: logoBytes,
      );

      Get.find<HomeController>().reinitializeController();
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

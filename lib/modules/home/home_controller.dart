// lib/home/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../routes/app_routes.dart';
import '../../services/token_storage.dart';
import '../order_details/order_details_controller.dart';

class HomeController extends GetxController {
  // --- auth/logout state ---
  final isLoggingOut = false.obs;

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await TokenStorage.clearToken();
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoggingOut.value = false;
    }
  }

  // --- location autofill state ---
  final isLocating = false.obs;

  // --- form controllers (customer details) ---
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // default fallback so nothing crashes if you navigate directly
    useCurrentLocation();
  }

  // Autofill address-related fields using current device location
  Future<void> useCurrentLocation() async {
    if (isLocating.value) return;
    isLocating.value = true;

    try {
      // 1. Check GPS service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "Location disabled",
          "Please turn on location services.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2. Permission check/request
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permission denied",
          "Please allow location permission.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 3. Current position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final streetPieces = <String>[
          if ((p.street ?? '').trim().isNotEmpty) p.street!,
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!,
        ];

        addressCtrl.text = streetPieces.join(', ');
        cityCtrl.text = (p.locality?.trim().isNotEmpty ?? false)
            ? p.locality!
            : (p.subAdministrativeArea ?? '');
        provinceCtrl.text = p.administrativeArea ?? '';
        postalCodeCtrl.text = p.postalCode ?? '';

        Get.snackbar(
          "Address filled",
          "Location captured successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "No address found",
          "Couldn't resolve an address for your location.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Location error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLocating.value = false;
    }
  }

  // Prepare data for OrderDetailsController and move to next screen
  void goNext() {
    final map = {
      "firstName": firstNameCtrl.text.trim(),
      "lastName": lastNameCtrl.text.trim(),
      "street": addressCtrl.text.trim(),
      "city": cityCtrl.text.trim(),
      "province": provinceCtrl.text.trim(),
      "postalCode": postalCodeCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "phone": contactCtrl.text.trim(),
    };

    // ensure OrderDetailsController exists
    if (!Get.isRegistered<OrderDetailsController>()) {
      Get.put(OrderDetailsController());
    }

    final orderCtrl = Get.find<OrderDetailsController>();
    orderCtrl.setCustomerInfoFromMap(map);

    Get.toNamed(AppRoutes.orderDetails);
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    provinceCtrl.dispose();
    postalCodeCtrl.dispose();
    contactCtrl.dispose();
    emailCtrl.dispose();
    super.onClose();
  }
}

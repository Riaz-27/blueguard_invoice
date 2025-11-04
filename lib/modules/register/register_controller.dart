import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/routes/app_routes.dart';

import '../../services/auth_services.dart';

class RegisterController extends GetxController {
  final isLoading = false.obs;

  // Form controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final _auth = AuthService();

  Future<void> register() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    try {
      isLoading.value = true;

      final res = await _auth.signup(
        name: name,
        email: email,
        password: password,
      );

      if (res.isSuccess) {
        Get.snackbar(
          'Success',
          res.message.isNotEmpty ? res.message : 'Registration successful',
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'Signup Failed',
          res.message.isNotEmpty ? res.message : 'Please try again.',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}

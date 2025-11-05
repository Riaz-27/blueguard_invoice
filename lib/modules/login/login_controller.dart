import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/routes/app_routes.dart';

import '../../services/auth_services.dart';
import '../../services/token_storage.dart';
import '../home/home_controller.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final _auth = AuthService();

  Future<void> login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    try {
      isLoading.value = true;

      final result = await _auth.login(email: email, password: password);

      if (result.isSuccess && result.user != null) {
        final user = result.user!;

        if (user.hasToken) {
          await TokenStorage.saveToken(user.token);
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().reinitializeController();
        }
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar(
          'Login Failed',
          result.message.isNotEmpty
              ? result.message
              : 'Invalid email or password',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

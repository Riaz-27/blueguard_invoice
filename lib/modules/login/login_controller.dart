import 'package:get/get.dart';
import 'package:invoice/routes/app_routes.dart';

import '../../services/auth_services.dart';
import '../../services/token_storage.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  final _auth = AuthService();

  Future<void> login() async {
    if (email.value.trim().isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Email and password are required');
      return;
    }

    try {
      isLoading.value = true;

      final result = await _auth.login(
        email: email.value,
        password: password.value,
      );

      if (result.isSuccess && result.user != null) {
        final user = result.user!;

        // token is already saved in AuthService.login() but just to be safe:
        if (user.hasToken) {
          await TokenStorage.saveToken(user.token);
        }

        Get.snackbar(
          'Welcome',
          user.name.isNotEmpty
              ? 'Hello ${user.name}'
              : (result.message.isNotEmpty
                    ? result.message
                    : 'Login successful'),
        );

        // ✅ Go to home page and clear back stack
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
}

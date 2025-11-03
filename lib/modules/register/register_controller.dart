import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../services/auth_services.dart';

class RegisterController extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  final _auth = AuthService();

  Future<void> register() async {
    if (name.value.trim().isEmpty ||
        email.value.trim().isEmpty ||
        password.value.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    try {
      isLoading.value = true;

      final res = await _auth.signup(
        name: name.value,
        email: email.value,
        password: password.value,
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
}

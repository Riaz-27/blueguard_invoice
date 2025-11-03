import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(
          () => Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => controller.email.value = v,
              ),
              12.h.verticalSpace,
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (v) => controller.password.value = v,
              ),
              20.h.verticalSpace,
              controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: const Text('Don’t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

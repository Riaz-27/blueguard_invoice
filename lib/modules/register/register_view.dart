import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(
          () => Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (v) => controller.name.value = v,
              ),
              12.h.verticalSpace,
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
                      onPressed: controller.register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                      child: const Text('Sign Up'),
                    ),
              TextButton(
                onPressed: () => Get.offAllNamed('/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

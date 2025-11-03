import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';
import 'register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  12.h.verticalSpace,
                  Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  6.h.verticalSpace,
                  Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  24.h.verticalSpace,

                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomFormField(
                            controller: controller.nameCtrl,
                            hintText: "Full name",
                            keyboardType: TextInputType.name,
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          14.h.verticalSpace,

                          CustomFormField(
                            controller: controller.emailCtrl,
                            hintText: "Email address",
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (v) {
                              final val = (v ?? '').trim();
                              if (val.isEmpty) return 'Email is required';
                              final ok = RegExp(
                                r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$",
                              ).hasMatch(val);
                              if (!ok) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          14.h.verticalSpace,

                          CustomFormField(
                            controller: controller.passwordCtrl,
                            hintText: "Password",
                            keyboardType: TextInputType.visiblePassword,
                            prefixIcon: Icons.lock_outline,
                            obscure: true,
                            showObscureToggle: true,
                            validator: (v) {
                              final val = (v ?? '');
                              if (val.isEmpty) return 'Password is required';
                              if (val.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          14.h.verticalSpace,

                          CustomFormField(
                            controller: controller.confirmCtrl,
                            hintText: "Confirm password",
                            keyboardType: TextInputType.visiblePassword,
                            prefixIcon: Icons.lock_reset_outlined,
                            obscure: true,
                            showObscureToggle: true,
                            validator: (v) {
                              final val = (v ?? '');
                              if (val.isEmpty) return 'Confirm your password';
                              if (val != controller.passwordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                          ),
                          18.h.verticalSpace,

                          Obx(
                            () => CustomButton(
                              label: "Create Account",
                              loading: controller.isLoading.value,
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                controller.register();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  16.h.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: const Color(0xFF2F7D61),
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

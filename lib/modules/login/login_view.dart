import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  12.h.verticalSpace,
                  Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  6.h.verticalSpace,
                  Text(
                    "Login to continue",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  24.h.verticalSpace,

                  // Card container
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomFormField(
                            controller: controller.emailCtrl,
                            hintText: "Enter your gmail",
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
                            textInputAction: TextInputAction.next,
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
                              if (val.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                          ),
                          24.h.verticalSpace,

                          // Login button
                          Obx(
                            () => CustomButton(
                              label: "Login",
                              loading: controller.isLoading.value,
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                controller.login();
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
                        "Don’t have an account?",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.register),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
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

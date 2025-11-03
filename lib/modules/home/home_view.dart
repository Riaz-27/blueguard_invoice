// lib/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Home",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          // Logout button
          Obx(() {
            final busy = controller.isLoggingOut.value;
            return IconButton(
              tooltip: "Logout",
              onPressed: busy ? null : controller.logout,
              icon: busy
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Icon(Icons.logout_rounded, color: Colors.red),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer Details",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              8.h.verticalSpace,
              Text(
                "Fill in the service address and contact. You can auto-fill address using GPS.",
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),

              24.h.verticalSpace,

              _LabeledField(
                label: "First Name:",
                controller: controller.firstNameCtrl,
                keyboardType: TextInputType.name,
              ),
              16.h.verticalSpace,

              _LabeledField(
                label: "Last Name:",
                controller: controller.lastNameCtrl,
                keyboardType: TextInputType.name,
              ),
              16.h.verticalSpace,

              _LabeledField(
                label: "Contact Number:",
                controller: controller.contactCtrl,
                keyboardType: TextInputType.phone,
              ),
              16.h.verticalSpace,

              _LabeledField(
                label: "Email:",
                controller: controller.emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              16.h.verticalSpace,

              // Address Line with suffix location icon
              Obx(() {
                final locating = controller.isLocating.value;
                return _LabeledField(
                  label: "Address Line:",
                  controller: controller.addressCtrl,
                  keyboardType: TextInputType.streetAddress,
                  suffix: IconButton(
                    tooltip: "Use current location",
                    onPressed: locating ? null : controller.useCurrentLocation,
                    icon: locating
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Colors.blueAccent,
                          ),
                  ),
                );
              }),
              16.h.verticalSpace,

              _LabeledField(
                label: "City:",
                controller: controller.cityCtrl,
                keyboardType: TextInputType.text,
              ),
              16.h.verticalSpace,

              _LabeledField(
                label: "Province:",
                controller: controller.provinceCtrl,
                keyboardType: TextInputType.text,
              ),
              16.h.verticalSpace,

              _LabeledField(
                label: "Postal Code:",
                controller: controller.postalCodeCtrl,
                keyboardType: TextInputType.text,
              ),
              16.h.verticalSpace,
              24.h.verticalSpace,

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: controller.goNext,
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              24.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.blueGrey.shade100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        6.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}

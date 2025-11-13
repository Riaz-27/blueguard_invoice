import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:invoice/utils/colors.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        centerTitle: false,
        actions: [
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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer Details",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
              6.h.verticalSpace,
              Text(
                "Add the contact information and service address below.",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              24.h.verticalSpace,

              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: borderColor, width: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            offset: Offset(0, 2),
                            blurRadius: 4.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel("First Name"),
                          CustomFormField(
                            controller: controller.firstNameCtrl,
                            hintText: "Enter first name",
                            keyboardType: TextInputType.name,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'First name is required'
                                : null,
                          ),
                          14.h.verticalSpace,

                          _FieldLabel("Last Name"),
                          CustomFormField(
                            controller: controller.lastNameCtrl,
                            hintText: "Enter last name",
                            keyboardType: TextInputType.name,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Last name is required'
                                : null,
                          ),
                          14.h.verticalSpace,

                          _FieldLabel("Contact Number"),
                          CustomFormField(
                            controller: controller.contactCtrl,
                            hintText: "Enter contact number",
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              final val = (v ?? '').trim();
                              if (val.isEmpty) {
                                return 'Phone number is required';
                              }
                              final digits = val.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 7) {
                                return 'Enter a valid phone';
                              }
                              return null;
                            },
                          ),
                          14.h.verticalSpace,

                          _FieldLabel("Email"),
                          CustomFormField(
                            controller: controller.emailCtrl,
                            hintText: "Enter email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final val = (v ?? '').trim();
                              if (val.isEmpty) return 'Email is required';
                              final ok = GetUtils.isEmail(v!);
                              return ok ? null : 'Enter a valid email';
                            },
                          ),
                        ],
                      ),
                    ),

                    8.h.verticalSpace,

                    // Address
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: borderColor, width: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            offset: Offset(0, 2),
                            blurRadius: 4.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FieldLabel("Address Line"),
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Text(
                              "Tip: tap the location icon inside the field to refresh from current location.",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black38,
                                height: 1.5,
                              ),
                            ),
                          ),
                          Obx(() {
                            final locating = controller.isLocating.value;
                            return CustomFormField(
                              controller: controller.addressCtrl,
                              hintText: "Street & area",
                              keyboardType: TextInputType.streetAddress,
                              suffix: IconButton(
                                tooltip: "Use current location",
                                onPressed: locating
                                    ? null
                                    : controller.useCurrentLocation,
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
                                        color: primaryColor,
                                        size: 20,
                                      ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Address is required'
                                  : null,
                            );
                          }),
                          14.h.verticalSpace,

                          _FieldLabel("City"),
                          CustomFormField(
                            controller: controller.cityCtrl,
                            hintText: "Enter city",
                            keyboardType: TextInputType.text,
                            // prefixIcon: Icons.location_city_outlined,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'City is required'
                                : null,
                          ),
                          14.h.verticalSpace,

                          _FieldLabel("Province"),
                          CustomFormField(
                            controller: controller.provinceCtrl,
                            hintText: "Enter province (optional)",
                            keyboardType: TextInputType.text,
                          ),
                          14.h.verticalSpace,

                          _FieldLabel("Postal Code"),
                          CustomFormField(
                            controller: controller.postalCodeCtrl,
                            hintText: "Enter postal code (optional)",
                            keyboardType: TextInputType.text,
                          ),
                        ],
                      ),
                    ),

                    18.h.verticalSpace,

                    CustomButton(
                      label: "Next",
                      loading: false,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.goNext();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}

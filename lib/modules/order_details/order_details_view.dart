import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../home/widgets/primary_button.dart';
import 'order_details_controller.dart';
import 'widgets/service_card_tile.dart';
import 'widgets/bottom_summary_bar.dart';
import 'widgets/labeled_field_block.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      /// sticky bottom summary (tax slab, subtotal, total, next btn)
      bottomNavigationBar: Obx(() {
        final sub = controller.subTotal;
        final taxP = controller.taxPercent;
        final taxVal = controller.taxAmount;
        final total = controller.totalAfterTax;

        return BottomSummaryBar(
          provinceChips: controller.taxRates.keys.toList(),
          selectedProvince: controller.selectedProvince.value,
          onSelectProvince: controller.selectProvince,
          subTotal: sub,
          taxPercent: taxP,
          taxAmount: taxVal,
          total: total,
          onNext: controller.isSubmitting.value ? null : controller.onNext,
          isLoading: controller.isSubmitting.value,
        );
      }),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------------------------------------------------
                  // SERVICES LIST (cart style cards)
                  // -------------------------------------------------
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  12.h.verticalSpace,

                  Obx(
                    () => ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.services.length,
                      separatorBuilder: (_, __) => 12.h.verticalSpace,
                      itemBuilder: (_, index) {
                        final item = controller.services[index];
                        return ServiceCardTile(
                          item: item,
                          onIncrement: () => controller.incrementQty(index),
                          onDecrement: () => controller.decrementQty(index),
                          onRemove: () => controller.removeService(index),
                        );
                      },
                    ),
                  ),

                  20.h.verticalSpace,

                  // -------------------------------------------------
                  // ADD SERVICE BUTTON (opens bottom sheet)
                  // -------------------------------------------------
                  PrimaryButton(
                    label: "Add Service",
                    onTap: () {
                      _openAddServiceSheet(controller);
                    },
                  ),

                  24.h.verticalSpace,

                  // -------------------------------------------------
                  // NEXT SERVICE DATE + COMMENTS
                  // -------------------------------------------------
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20.r,
                          offset: const Offset(0, 8),
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Next Service Date
                        LabeledFieldBlock(
                          label: "Next Service Date:",
                          child: TextField(
                            controller: controller.nextServiceDateCtrl,
                            readOnly: true,
                            onTap: () =>
                                controller.pickNextServiceDate(context),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: const Color(0xFFD1D9E6),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: const Color(0xFFD1D9E6),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: const Color(0xFF4F46E5),
                                  width: 1.4,
                                ),
                              ),
                              hintText: "mm/dd/yyyy",
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        20.h.verticalSpace,

                        // Comments dropdown
                        Obx(
                          () => LabeledFieldBlock(
                            label: "Comments:",
                            child: DropdownButtonFormField<String>(
                              value: controller.commentType.value,
                              items: controller.commentOptions
                                  .map(
                                    (opt) => DropdownMenuItem(
                                      value: opt,
                                      child: Text(
                                        opt,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  controller.commentType.value = v;
                                }
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFD1D9E6),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFD1D9E6),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4F46E5),
                                    width: 1.4,
                                  ),
                                ),
                                hintText: "Select an option",
                              ),
                            ),
                          ),
                        ),

                        16.h.verticalSpace,

                        // Multiline comments box
                        TextField(
                          controller: controller.commentCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Write extra notes here...",
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: const Color(0xFFD1D9E6),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: const Color(0xFFD1D9E6),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: const Color(0xFF4F46E5),
                                width: 1.4,
                              ),
                            ),
                            fillColor: const Color(0xFFFDFEFE),
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  120
                      .h
                      .verticalSpace, // leave room so bottom bar doesn't cover content
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAddServiceSheet(OrderDetailsController controller) {
    final TextEditingController priceCtrl = TextEditingController(text: "0");
    final TextEditingController qtyCtrl = TextEditingController(text: "1");

    final RxString selectedService =
        (controller.serviceOptions.isNotEmpty
                ? controller.serviceOptions.first
                : "")
            .obs;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Service",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                20.h.verticalSpace,

                // Service dropdown
                Text(
                  "Services Availed:",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                6.h.verticalSpace,
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: selectedService.value.isEmpty
                        ? null
                        : selectedService.value,
                    items: controller.serviceOptions
                        .map(
                          (opt) => DropdownMenuItem(
                            value: opt,
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        selectedService.value = v;
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: const Color(0xFFD1D9E6),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: const Color(0xFFD1D9E6),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: const Color(0xFF4F46E5),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),

                16.h.verticalSpace,

                // Price
                Text(
                  "Price:",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                6.h.verticalSpace,
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: const Color(0xFFD1D9E6),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: const Color(0xFFD1D9E6),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: const Color(0xFF4F46E5),
                        width: 1.4,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),

                16.h.verticalSpace,

                // Quantity
                Text(
                  "Quantity:",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                6.h.verticalSpace,
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: const Color(0xFFD1D9E6),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: const Color(0xFFD1D9E6),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: const Color(0xFF4F46E5),
                        width: 1.4,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),

                24.h.verticalSpace,

                PrimaryButton(
                  label: "Add",
                  onTap: () {
                    final name = selectedService.value.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;

                    if (name.isEmpty) {
                      Get.snackbar("Invalid", "Please choose a service.");
                      return;
                    }

                    controller.addService(
                      name: name,
                      price: price,
                      qty: qty < 1 ? 1 : qty,
                    );

                    Get.back(); // close bottom sheet
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }
}

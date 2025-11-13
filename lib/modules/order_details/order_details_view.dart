import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:invoice/utils/colors.dart';
import 'package:invoice/widgets/custom_button.dart';
import 'package:invoice/widgets/custom_form_field.dart';

import 'order_details_controller.dart';
import 'widgets/service_card_tile.dart';
import 'widgets/bottom_summary_bar.dart';
import 'widgets/labeled_field_block.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      bottomNavigationBar: Obx(() {
        final sub = controller.subTotal;
        final taxP = controller.taxPercent;
        final taxVal = controller.taxAmount;
        final total = controller.totalAfterTax;

        return BottomSummaryBar(
          itemKey: controller.itemKey,
          scrollController: controller.scrollController,
          taxSlabs: controller.taxRates.keys.toList(),
          selectedTaxSlab: controller.selectedTaxSlab.value,
          onSelectTaxSlab: controller.selectTaxSlab,
          subTotal: sub,
          taxPercent: taxP,
          taxAmount: taxVal,
          total: total,
          onNext: controller.isSubmitting.value ? null : controller.onNext,
          isLoading: controller.isLoading.value,
          primaryLabel: "Generate Invoice",
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
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  12.h.verticalSpace,

                  Obx(() {
                    if (controller.services.isEmpty) {
                      return Center(
                        child: Text(
                          '-- Service List is empty. Start by adding new --',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black38,
                          ),
                        ),
                      );
                    }
                    return Container(
                      padding: EdgeInsets.all(12.w),
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
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: controller.services.length,
                        separatorBuilder: (_, __) => 8.h.verticalSpace,
                        itemBuilder: (_, index) {
                          final item = controller.services[index];
                          return ServiceCardTile(
                            item: item,
                            onIncrement: () => controller.incrementQty(index),
                            onDecrement: () => controller.decrementQty(index),
                            onRemove: () => controller.removeService(index),
                            onTitleTap: () =>
                                _openServiceSheet(controller, editIndex: index),
                          );
                        },
                      ),
                    );
                  }),

                  20.h.verticalSpace,

                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() {
                      final isLoading = controller.isLoading.value;
                      return CustomButton(
                        label: "+ Add Service",
                        txtStyle: TextStyle(fontSize: 14.sp),
                        height: 45,
                        btnColor: primaryColor.withAlpha(20),
                        txtColor: primaryColor,
                        borderColor: primaryColor,
                        isExpanded: false,
                        loading: isLoading,
                        onPressed: () => _openServiceSheet(controller),
                      );
                    }),
                  ),
                  24.h.verticalSpace,

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
                        Obx(
                          () => LabeledFieldBlock(
                            label: "Payment Method",
                            child: DropdownButtonFormField<String>(
                              value: controller.paymentMethod.value,
                              items: controller.paymentOptions
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
                              onChanged: controller.onPaymentChange,
                              isExpanded: true,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2F7D61),
                                    width: 1.2,
                                  ),
                                ),
                                hintText: "Select a method",
                              ),
                            ),
                          ),
                        ),
                        20.h.verticalSpace,
                        // Date
                        LabeledFieldBlock(
                          label: "Next Service Date",
                          child: CustomFormField(
                            controller: controller.nextServiceDateCtrl,
                            hintText: "mm/dd/yyyy",
                            keyboardType: TextInputType.datetime,
                            prefixIcon: Icons.calendar_today,
                            readOnly: true,
                            onTap: () =>
                                controller.pickNextServiceDate(context),
                            textInputAction: TextInputAction.next,
                          ),
                        ),

                        20.h.verticalSpace,

                        Obx(
                          () => LabeledFieldBlock(
                            label: "Comments",
                            child: DropdownButtonFormField<String>(
                              initialValue: controller.commentType.value,
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
                              onChanged: controller.onCommentChange,
                              isExpanded: true,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2F7D61),
                                    width: 1.2,
                                  ),
                                ),
                                hintText: "Select a preset",
                              ),
                            ),
                          ),
                        ),

                        16.h.verticalSpace,

                        CustomFormField(
                          controller: controller.commentCtrl,
                          hintText: "Write extra notes here...",
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),

                  120.h.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add/Edit bottom sheet
  void _openServiceSheet(OrderDetailsController controller, {int? editIndex}) {
    final isEdit = editIndex != null;
    final initial = isEdit ? controller.services[editIndex] : null;

    final priceCtrl = TextEditingController(text: initial?.price.toString());
    final qtyCtrl = TextEditingController(text: (initial?.qty ?? 1).toString());

    // Build a filtered options list
    final existing = controller.services.map((e) => e.name).toSet();
    final availableOptions = controller.serviceOptions.where((opt) {
      if (isEdit && opt == initial!.name) return true;
      return !existing.contains(opt);
    }).toList();

    // Choose initial selection:
    final String initialSelection = isEdit
        ? initial!.name
        : (availableOptions.isNotEmpty ? availableOptions.first : "");
    final RxString selectedService = initialSelection.obs;

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
                  isEdit ? "Edit Service" : "Add Service",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                20.h.verticalSpace,

                _FieldLabel("Services Availed"),
                6.h.verticalSpace,

                // If no options left to add (and not editing), show a tip
                if (!isEdit && availableOptions.isEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "All services have been added already.",
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    ),
                  ),
                  12.h.verticalSpace,
                ],

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: selectedService.value.isEmpty
                        ? null
                        : selectedService.value,
                    items: availableOptions
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
                      if (v == null) return;
                      selectedService.value = v;
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: Color(0xFF2F7D61),
                          width: 1.2,
                        ),
                      ),
                      hintText: availableOptions.isEmpty
                          ? "No services available"
                          : "Select a service",
                    ),
                  ),
                ),

                16.h.verticalSpace,

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel("Price"),
                          6.h.verticalSpace,
                          CustomFormField(
                            controller: priceCtrl,
                            hintText: "Enter price",
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefixIcon: Icons.attach_money_rounded,
                            validator: (v) {
                              final d = double.tryParse((v ?? '').trim());
                              if (d == null || d < 0) {
                                return 'Enter a valid price';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    12.w.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel("Quantity"),
                          6.h.verticalSpace,
                          CustomFormField(
                            controller: qtyCtrl,
                            hintText: "Enter quantity",
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.onetwothree_outlined,
                            validator: (v) {
                              final q = int.tryParse((v ?? '').trim());
                              if (q == null || q < 1) {
                                return 'Enter a valid quantity';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                16.h.verticalSpace,

                24.h.verticalSpace,

                // Disable Add when nothing available to add
                CustomButton(
                  label: isEdit ? "Save" : "Add",
                  onPressed: (!isEdit && availableOptions.isEmpty)
                      ? null
                      : () {
                          final name = selectedService.value.trim();
                          final price =
                              double.tryParse(priceCtrl.text.trim()) ?? 0;
                          final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;

                          if (name.isEmpty) {
                            Get.snackbar("Invalid", "Please choose a service.");
                            return;
                          }

                          // Second safeguard: no duplicates on Add,
                          // and also prevent renaming to an existing name on Edit.
                          final exists = controller.services.any(
                            (s) => s.name == name,
                          );
                          if (!isEdit && exists) {
                            Get.snackbar(
                              "Duplicate",
                              "This service is already added.",
                            );
                            return;
                          }
                          if (isEdit && name != initial!.name && exists) {
                            Get.snackbar(
                              "Duplicate",
                              "Another service with this name already exists.",
                            );
                            return;
                          }

                          if (isEdit) {
                            controller.updateService(
                              index: editIndex,
                              name: name,
                              price: price < 0 ? 0 : price,
                              qty: qty < 1 ? 1 : qty,
                            );
                          } else {
                            controller.addService(
                              name: name,
                              price: price < 0 ? 0 : price,
                              qty: qty < 1 ? 1 : qty,
                            );
                          }

                          Get.back();
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
